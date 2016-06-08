#include "windows/main_window.h"
#include "modules/accel_session_handler.h"

static Window *s_window;
static StatusBarLayer *s_status_bar;
static ActionBarLayer *s_action_bar_layer;

static TextLayer *s_stopwatch_layer;
static GBitmap *s_record_bitmap, *s_stop_bitmap, *s_marker_bitmap;

static bool session_running = false;

static void stopwatch_update_handler(double elapsed_seconds) {
    int seconds = (int)elapsed_seconds % 60;
    int minutes = (int)elapsed_seconds / 60 % 60;

    static char buffer[6];
    snprintf(buffer, 6, "%02d:%02d", minutes, seconds);

    text_layer_set_text(s_stopwatch_layer, buffer);
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
    session_running = !session_running;

    if(session_running) {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_stop_bitmap);
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_DOWN, s_marker_bitmap);

        accel_session_start(stopwatch_update_handler);
    } else {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_record_bitmap);
        action_bar_layer_clear_icon(s_action_bar_layer, BUTTON_ID_DOWN);

        accel_session_finish();

        text_layer_set_text(s_stopwatch_layer, "00:00");
    }
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
    if(session_running) {
        accel_session_add_marker();
    }
}

static void click_config_provider(void *context) {
    window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
    window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window) {
    Layer *window_layer = window_get_root_layer(window);
    GRect bounds = layer_get_bounds(window_layer);

    s_record_bitmap = gbitmap_create_with_resource(RESOURCE_ID_RECORD);
    s_stop_bitmap = gbitmap_create_with_resource(RESOURCE_ID_STOP);
    s_marker_bitmap = gbitmap_create_with_resource(RESOURCE_ID_MARKER);

    s_action_bar_layer = action_bar_layer_create();
    action_bar_layer_set_click_config_provider(s_action_bar_layer, click_config_provider);
    action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_record_bitmap);
    action_bar_layer_add_to_window(s_action_bar_layer, window);

    int16_t width = bounds.size.w - ACTION_BAR_WIDTH;

    s_status_bar = status_bar_layer_create();
    status_bar_layer_set_colors(s_status_bar, GColorClear, GColorBlack);
    GRect frame = GRect(0, 0, width, STATUS_BAR_LAYER_HEIGHT);
    layer_set_frame(status_bar_layer_get_layer(s_status_bar), frame);
    layer_add_child(window_layer, status_bar_layer_get_layer(s_status_bar));

    s_stopwatch_layer = text_layer_create(GRect(0, bounds.size.h / 2 - 32, width, 32));
    text_layer_set_font(s_stopwatch_layer, fonts_get_system_font(FONT_KEY_LECO_32_BOLD_NUMBERS));
    text_layer_set_background_color(s_stopwatch_layer, GColorClear);
    text_layer_set_text_color(s_stopwatch_layer, GColorBlack);
    text_layer_set_text_alignment(s_stopwatch_layer, GTextAlignmentCenter);
    text_layer_set_text(s_stopwatch_layer, "00:00");
    layer_add_child(window_layer, text_layer_get_layer(s_stopwatch_layer));
}

static void window_unload(Window *window) {
    text_layer_destroy(s_stopwatch_layer);

    gbitmap_destroy(s_record_bitmap);
    gbitmap_destroy(s_stop_bitmap);
    gbitmap_destroy(s_marker_bitmap);

    status_bar_layer_destroy(s_status_bar);
    action_bar_layer_destroy(s_action_bar_layer);
    window_destroy(window);
}

void main_window_push() {
    if(!s_window) {
        s_window = window_create();
        window_set_window_handlers(s_window, (WindowHandlers) {
            .load = window_load,
            .unload = window_unload,
        });
    }

    window_stack_push(s_window, true);
}
