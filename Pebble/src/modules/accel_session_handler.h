#pragma once

#include <pebble.h>

typedef void(* AccelSessionStopwatchCallback)(double elapsed_time_ms);

void accel_session_start(AccelSessionStopwatchCallback callback);
void accel_session_finish();

void accel_session_add_marker();
