#include <pebble_worker.h>

static const int ACCEL_NUM_SAMPLES = 10;
static const int STOPWATCH_STEP_MS = 1000;

static AppTimer* stopwatch_timer = NULL;
static double logging_start_time = 0; // In seconds

static uint16_t current_session_index = 0;

static int16_t collected_accel_data[2700];
static int16_t collected_data_cursor = 0;

static uint32_t sessions_start_time[36]; // In seconds
static uint16_t sessions_data_cursors_beginnings[36];

static uint32_t markers_time_adding[60]; // In seconds
static uint16_t current_markers_index = 0;

static double seconds_from_epoch() {
    time_t seconds;
    uint16_t milliseconds;
    time_ms(&seconds, &milliseconds);
    return (double)seconds + ((double)milliseconds / 1000.0);
}

static void handle_timer() {
    double now = seconds_from_epoch();
    double elapsed_time = now - logging_start_time;

    uint16_t seconds = (int)elapsed_time % 60;
    uint16_t minutes = (int)elapsed_time / 60 % 60;

    AppWorkerMessage msg_data = { .data0 = seconds, .data1 = minutes };
    app_worker_send_message(5, &msg_data);

    stopwatch_timer = app_timer_register(STOPWATCH_STEP_MS, handle_timer, NULL);
}

static void handle_accel_data(AccelData *data, uint32_t num_samples) {
    for(int i = 0; i < (int)num_samples; i++) {
        AccelData data_sample = data[i];

        collected_accel_data[collected_data_cursor] = data_sample.x;
        collected_data_cursor++;
        collected_accel_data[collected_data_cursor] = data_sample.y;
        collected_data_cursor++;
        collected_accel_data[collected_data_cursor] = data_sample.z;
        collected_data_cursor++;
    }
}

static void accel_data_logging_start() {
    logging_start_time = seconds_from_epoch();
    sessions_start_time[current_session_index] = logging_start_time;
    sessions_data_cursors_beginnings[current_session_index] = collected_data_cursor;

    stopwatch_timer = app_timer_register(STOPWATCH_STEP_MS, handle_timer, NULL);

    accel_data_service_subscribe(ACCEL_NUM_SAMPLES, handle_accel_data);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

static void accel_data_logging_finish() {
    app_timer_cancel(stopwatch_timer);
    stopwatch_timer = NULL;

    accel_data_service_unsubscribe();

    current_session_index++;
}

static void handle_app_worker_messages(uint16_t type, AppWorkerMessage *data) {
    switch(type){
        case 1: // Start accel data logging WORKER_MESSAGE_START
        accel_data_logging_start();
        break;
        case 2: // Finish accel data logging
        accel_data_logging_finish();
        break;
        case 5: // Sync date. data0 - minutes, data1 - seconds
        break;
        case 6: // Add marker
        markers_time_adding[current_markers_index] = (int)seconds_from_epoch();
        current_markers_index++;
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
