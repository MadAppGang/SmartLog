#include <pebble_worker.h>

static const int ACCEL_NUM_SAMPLES = 10;
static const int STOPWATCH_STEP_MS = 1000;

static AppTimer* stopwatch_timer = NULL;
static uint32_t logging_start_time = 0; // In seconds

static DataLoggingSessionRef s_accel_data_session_ref, s_start_date_session_ref, s_markers_session_ref;

typedef struct __attribute__((__packed__)) {
    int16_t x;          // 2 bytes
    int16_t y;          // 2 bytes
    int16_t z;          // 2 bytes
    uint32_t timestamp; // 4 bytes
} AccelDataLogItem;     // 10 bytes

static uint32_t seconds_from_epoch() {
    time_t seconds;
    time(&seconds);
    return seconds;
}

static void send_worker_message_session_running() {
    uint16_t session_running = stopwatch_timer != NULL ? 1 : 0;
    AppWorkerMessage msg_data = { .data0 = session_running };
    app_worker_send_message(4, &msg_data);
}

static void handle_timer() {
    uint32_t now = seconds_from_epoch();
    uint32_t elapsed_time = now - logging_start_time;

    uint16_t seconds = elapsed_time % 60;
    uint16_t minutes = elapsed_time / 60 % 60;

    AppWorkerMessage msg_data = { .data0 = seconds, .data1 = minutes };
    app_worker_send_message(5, &msg_data);

    stopwatch_timer = app_timer_register(STOPWATCH_STEP_MS, handle_timer, NULL);
}

static void handle_accel_data(AccelData *data, uint32_t num_samples) {
    uint32_t now = seconds_from_epoch();

    for(int i = 0; i < (int)num_samples; i++) {
        AccelData data_sample = data[i];

        AccelDataLogItem accel_data_item = (AccelDataLogItem) {
            .x = data_sample.x,
            .y = data_sample.y,
            .z = data_sample.z,
            .timestamp = now
        };

        data_logging_log(s_accel_data_session_ref, &accel_data_item, 1);
    }
}

static void accel_data_logging_start() {
    s_start_date_session_ref = data_logging_create(100, DATA_LOGGING_UINT, sizeof(uint32_t), false);
    s_accel_data_session_ref = data_logging_create(101, DATA_LOGGING_BYTE_ARRAY, sizeof(AccelDataLogItem), false);
    s_markers_session_ref = data_logging_create(102, DATA_LOGGING_UINT, sizeof(uint32_t), false);

    logging_start_time = seconds_from_epoch();
    data_logging_log(s_start_date_session_ref, &logging_start_time, 1);

    stopwatch_timer = app_timer_register(STOPWATCH_STEP_MS, handle_timer, NULL);

    accel_data_service_subscribe(ACCEL_NUM_SAMPLES, handle_accel_data);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

static void accel_data_logging_finish() {
    app_timer_cancel(stopwatch_timer);
    stopwatch_timer = NULL;

    accel_data_service_unsubscribe();

    data_logging_finish(s_start_date_session_ref);
    data_logging_finish(s_accel_data_session_ref);
    data_logging_finish(s_markers_session_ref);
}

static void handle_app_worker_messages(uint16_t type, AppWorkerMessage *data) {
    uint32_t now = seconds_from_epoch();

    switch(type){
        case 1: // Start accel data logging WORKER_MESSAGE_START
        accel_data_logging_start();
        break;
        case 2: // Finish accel data logging
        accel_data_logging_finish();
        break;
        case 3: // Request session running
        send_worker_message_session_running();
        break;
        case 4: // Response session running
        break;
        case 5: // Stopwatch update
        break;
        case 6: // Add marker
        data_logging_log(s_markers_session_ref, &now, 1);
        break;
        default:
        break;
    }
}

static void init() {
    app_worker_message_subscribe(handle_app_worker_messages);
}

static void deinit() {
    app_worker_message_unsubscribe();
}

int main(void) {
    init();
    worker_event_loop();
    deinit();
}
