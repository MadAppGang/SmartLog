#include <pebble.h>

#include "windows/main_window.h"

static Window *s_window;
static StatusBarLayer *s_status_bar;
static ActionBarLayer *s_action_bar_layer;

static TextLayer *s_stopwatch_layer, *s_info_layer, *s_kit_connection_layer, *s_app_connection_layer;
static GBitmap *s_record_bitmap, *s_stop_bitmap, *s_marker_bitmap;

static bool session_running = false;

// MARK: - Common

static void update_action_bar(bool data_logging_enabled) {
    if(data_logging_enabled) {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_stop_bitmap);
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_DOWN, s_marker_bitmap);
    } else {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_record_bitmap);
        action_bar_layer_clear_icon(s_action_bar_layer, BUTTON_ID_DOWN);
    }
}

// MARK: - Buttons

static void handle_click_select(ClickRecognizerRef recognizer, void *context) {
    session_running = !session_running;

    update_action_bar(session_running);

    if(session_running) {
        AppWorkerMessage msg_data = { .data0 = 0 };
        app_worker_send_message(1, &msg_data);
    } else {
        text_layer_set_text(s_stopwatch_layer, "00:00");

        AppWorkerMessage msg_data = { .data0 = 0 };
        app_worker_send_message(2, &msg_data);
    }
}

static void handle_click_down(ClickRecognizerRef recognizer, void *context) {
    if(session_running) {
        AppWorkerMessage msg_data = { .data0 = 0 };
        app_worker_send_message(6, &msg_data);
    }
}

static void click_config_provider(void *context) {
    window_single_click_subscribe(BUTTON_ID_SELECT, handle_click_select);
    window_single_click_subscribe(BUTTON_ID_DOWN, handle_click_down);
}

// MARK: - Events

static void handle_pebblekit_connection(bool connected) {
    if(connected) {
        text_layer_set_text(s_kit_connection_layer, "Kit: YES");
    } else {
        text_layer_set_text(s_kit_connection_layer, "Kit: NO");
    }
}

static void handle_app_connection(bool connected) {
    if(connected) {
        text_layer_set_text(s_app_connection_layer, "App: YES");
    } else {
        text_layer_set_text(s_app_connection_layer, "App: NO");
    }
}

static void handle_app_worker_messages(uint16_t type, AppWorkerMessage *data) {
    if(type == 5) {
        static char buffer[6];
        snprintf(buffer, 6, "%02d:%02d", data->data1, data->data0);
        text_layer_set_text(s_stopwatch_layer, buffer);
    } else if(type == 4) {
        session_running = data->data0;
        update_action_bar(session_running);
    }
}

// MARK: - Lifecycle

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

    s_info_layer = text_layer_create(GRect(0, bounds.size.h / 2 + 4, width, bounds.size.h / 2 - 4));
    text_layer_set_text_alignment(s_info_layer, GTextAlignmentCenter);
    layer_add_child(window_layer, text_layer_get_layer(s_info_layer));

    s_app_connection_layer = text_layer_create(GRect(2, STATUS_BAR_LAYER_HEIGHT, width - 2, 16));
    layer_add_child(window_layer, text_layer_get_layer(s_app_connection_layer));

    s_kit_connection_layer = text_layer_create(GRect(2, STATUS_BAR_LAYER_HEIGHT + 16, width - 2, 16));
    layer_add_child(window_layer, text_layer_get_layer(s_kit_connection_layer));

    handle_pebblekit_connection(connection_service_peek_pebblekit_connection());
    handle_app_connection(connection_service_peek_pebble_app_connection());

    connection_service_subscribe((ConnectionHandlers) {
        .pebblekit_connection_handler = handle_pebblekit_connection,
        .pebble_app_connection_handler = handle_app_connection,
    });

    app_worker_message_subscribe(handle_app_worker_messages);

    AppWorkerMessage msg_data = { .data0 = 0 };
    app_worker_send_message(3, &msg_data);
}

static void window_unload(Window *window) {
    text_layer_destroy(s_stopwatch_layer);
    text_layer_destroy(s_info_layer);
    text_layer_destroy(s_kit_connection_layer);
    text_layer_destroy(s_app_connection_layer);

    gbitmap_destroy(s_record_bitmap);
    gbitmap_destroy(s_stop_bitmap);
    gbitmap_destroy(s_marker_bitmap);

    status_bar_layer_destroy(s_status_bar);
    action_bar_layer_destroy(s_action_bar_layer);
    window_destroy(window);

    connection_service_unsubscribe();

    app_worker_message_unsubscribe();
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
