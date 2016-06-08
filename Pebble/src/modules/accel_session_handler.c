#include "modules/accel_session_handler.h"

static const uint32_t ACCEL_NUM_SAMPLES = 10;
static const int SESSION_STOPWATCH_STEP_MS = 1000;

static AccelSessionStopwatchCallback accel_session_stopwatch_callback;

static AppTimer* session_stopwatch_timer = NULL;
static bool session_started = false;
static double session_start_time = 0; // In seconds

static double seconds_from_epoch() {
    time_t seconds;
    uint16_t milliseconds;
    time_ms(&seconds, &milliseconds);
    return (double)seconds + ((double)milliseconds / 1000.0);
}

static void handle_timer() {
    if(session_started) {
        double now = seconds_from_epoch();
        double elapsed_time = now - session_start_time;
        session_stopwatch_timer = app_timer_register(SESSION_STOPWATCH_STEP_MS, handle_timer, NULL);

        accel_session_stopwatch_callback(elapsed_time);
    }
}

static void handle_accel_data(AccelData *data, uint32_t num_samples) {
    for(int i = 0; i < (int)num_samples; i++) {
        AccelData data_sample = data[i];

        if(!data_sample.did_vibrate) {

        }
    }
}

void accel_session_start(AccelSessionStopwatchCallback callback) {
    accel_session_stopwatch_callback = callback;
    session_started = true;
    session_start_time = seconds_from_epoch();

    session_stopwatch_timer = app_timer_register(SESSION_STOPWATCH_STEP_MS, handle_timer, NULL);

    accel_data_service_subscribe(ACCEL_NUM_SAMPLES, handle_accel_data);
    accel_service_set_sampling_rate(ACCEL_SAMPLING_10HZ);
}

void accel_session_finish() {
    session_started = false;

    app_timer_cancel(session_stopwatch_timer);
    session_stopwatch_timer = NULL;

    accel_data_service_unsubscribe();
}

void accel_session_add_marker() {

}
