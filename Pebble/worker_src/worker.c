#include <pebble_worker.h>

typedef struct __attribute__((__packed__)) {
    int16_t x;          // 2 bytes
    int16_t y;          // 2 bytes
    int16_t z;          // 2 bytes
    uint32_t timestamp; // 4 bytes
} AccelDataLogItem;     // 10 bytes

static const int ACCEL_NUM_SAMPLES = 10;

static uint32_t s_logging_start_time = 0; // In seconds
static uint8_t s_markers_count = 0;
static uint8_t s_activity_type = 0;

static DataLoggingSessionRef s_accel_data_session_ref, s_markers_session_ref, s_activity_type_session_ref;

static uint32_t seconds_from_epoch() {
    time_t seconds;
    time(&seconds);
    return seconds;
}

static void add_marker() {
    s_markers_count++;

    uint32_t now = seconds_from_epoch();
    data_logging_log(s_markers_session_ref, &now, 1);
}

static void send_worker_message_session_data() {
    uint16_t elapsed_time;
    if(s_logging_start_time == 0) {
        elapsed_time = 0;
    } else {
        uint32_t now = seconds_from_epoch();
        elapsed_time = now - s_logging_start_time;
    }

    AppWorkerMessage msg_data = {
        .data0 = elapsed_time,
        .data1 = s_markers_count,
        .data2 = s_activity_type
    };
    app_worker_send_message(4, &msg_data);
}

static void handle_accel_data(AccelData *data, uint32_t num_samples) {
    uint32_t now = seconds_from_epoch();

    AccelDataLogItem accel_data_item = {
        .x = 0,
        .y = 0,
        .z = 0,
        .timestamp = now
    };

    for(int i = 0; i < (int)num_samples; i++) {
        accel_data_item.x = data[i].x;
        accel_data_item.y = data[i].y;
        accel_data_item.z = data[i].z;

        data_logging_log(s_accel_data_session_ref, &accel_data_item, 1);
    }
}

static void accel_data_logging_start(uint8_t activity_type) {
    s_accel_data_session_ref = data_logging_create(101, DATA_LOGGING_BYTE_ARRAY, sizeof(AccelDataLogItem), false);
    s_markers_session_ref = data_logging_create(102, DATA_LOGGING_UINT, sizeof(uint32_t), false);
    s_activity_type_session_ref = data_logging_create(103, DATA_LOGGING_UINT, sizeof(uint8_t), false);

    s_logging_start_time = seconds_from_epoch();
    s_markers_count = 0;
    s_activity_type = activity_type;
    data_logging_log(s_activity_type_session_ref, &activity_type, 1);

    accel_data_service_subscribe(ACCEL_NUM_SAMPLES, handle_accel_data);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

static void accel_data_logging_finish() {
    s_logging_start_time = 0;
    s_markers_count = 0;

    accel_data_service_unsubscribe();

    data_logging_finish(s_accel_data_session_ref);
    data_logging_finish(s_markers_session_ref);
    data_logging_finish(s_activity_type_session_ref);
}

static void handle_app_worker_messages(uint16_t type, AppWorkerMessage *data) {
    switch(type){
        case 1:
        accel_data_logging_start(data->data0);
        break;
        case 2:
        accel_data_logging_finish();
        break;
        case 3:
        send_worker_message_session_data();
        break;
        case 6:
        add_marker();
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
