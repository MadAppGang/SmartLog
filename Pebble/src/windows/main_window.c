#include <pebble.h>

#include "windows/main_window.h"

static Window *s_window;
static StatusBarLayer *s_status_bar;
static ActionBarLayer *s_action_bar_layer;

static TextLayer *s_stopwatch_layer, *s_activity_label_layer, *s_kit_connection_layer, *s_markers_count_layer;
static BitmapLayer *s_activity_icon_layer;

static GBitmap *s_icon_record, *s_icon_stop, *s_icon_add_marker;
static GBitmap *s_icon_up, *s_icon_down;
static GBitmap *s_icon_default_activity, *s_icon_stroke_butterfly, *s_icon_stroke_breast, *s_icon_stroke_back, *s_icon_stroke_freestyle;

static uint8_t activity_type = 0;

static bool session_running = false;

// MARK: - Common

static void update_action_bar(bool data_logging_enabled) {
    if(data_logging_enabled) {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_icon_stop);
        action_bar_layer_clear_icon(s_action_bar_layer, BUTTON_ID_UP);
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_DOWN, s_icon_add_marker);
    } else {
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_icon_record);
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_UP, s_icon_up);
        action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_DOWN, s_icon_down);
    }
}

// MARK: - Activities

static GBitmap* activity_icon(uint8_t activity_type) {
    switch(activity_type) {
        case 1:
        return s_icon_stroke_butterfly;
        case 2:
        return s_icon_stroke_back;
        case 3:
        return s_icon_stroke_breast;
        case 4:
        return s_icon_stroke_freestyle;
        default:
        return s_icon_default_activity;
    }
}

static const char* activity_label_text(uint8_t activity_type) {
    switch(activity_type) {
        case 1:
        return "Butterfly";
        case 2:
        return "Backstroke";
        case 3:
        return "Breaststroke";
        case 4:
        return "Freestyle";
        default:
        return "Not selected";
    }
}

// MARK: - Buttons

static void handle_click_select(ClickRecognizerRef recognizer, void *context) {
    session_running = !session_running;
    update_action_bar(session_running);

    AppWorkerMessage msg_data = { .data0 = 0 };

    if(session_running) {
        app_worker_send_message(1, &msg_data);
    } else {
        text_layer_set_text(s_stopwatch_layer, "00:00");
        app_worker_send_message(2, &msg_data);
    }
}

static void handle_click_up(ClickRecognizerRef recognizer, void *context) {
    if(!session_running) {
        if(activity_type == 4) {
            activity_type = 0;
        } else {
            activity_type++;
        }

        bitmap_layer_set_bitmap(s_activity_icon_layer, activity_icon(activity_type));
        text_layer_set_text(s_activity_label_layer, activity_label_text(activity_type));
    }
}

static void handle_click_down(ClickRecognizerRef recognizer, void *context) {
    if(session_running) {
        AppWorkerMessage msg_data = { .data0 = 0 };
        app_worker_send_message(6, &msg_data);
    } else {
        if(activity_type == 0) {
            activity_type = 4;
        } else {
            activity_type--;
        }

        bitmap_layer_set_bitmap(s_activity_icon_layer, activity_icon(activity_type));
        text_layer_set_text(s_activity_label_layer, activity_label_text(activity_type));
    }
}

static void click_config_provider(void *context) {
    window_single_click_subscribe(BUTTON_ID_SELECT, handle_click_select);
    window_single_click_subscribe(BUTTON_ID_UP, handle_click_up);
    window_single_click_subscribe(BUTTON_ID_DOWN, handle_click_down);
}

// MARK: - Events

static void handle_pebblekit_connection(bool connected) {
    if(connected) {
        text_layer_set_text(s_kit_connection_layer, "Connected");
    } else {
        text_layer_set_text(s_kit_connection_layer, "Not connected");
    }
}

static void handle_app_worker_messages(uint16_t type, AppWorkerMessage *data) {
    // if(type == 5) {
    //     static char buffer[6];
    //     snprintf(buffer, 6, "%02d:%02d", data->data1, data->data0);
    //     text_layer_set_text(s_stopwatch_layer, buffer);
    // } else
    if(type == 4) {
        session_running = data->data0;
        update_action_bar(session_running);
    }
}

// MARK: - Lifecycle

static void window_load(Window *window) {
    Layer *window_layer = window_get_root_layer(window);
    GRect bounds = layer_get_bounds(window_layer);

    s_icon_stop = gbitmap_create_with_resource(RESOURCE_ID_STOP);
    s_icon_add_marker = gbitmap_create_with_resource(RESOURCE_ID_MARKER);
    s_icon_record = gbitmap_create_with_resource(RESOURCE_ID_RECORD);
    s_icon_up = gbitmap_create_with_resource(RESOURCE_ID_UP);
    s_icon_down = gbitmap_create_with_resource(RESOURCE_ID_DOWN);
    s_icon_stroke_butterfly = gbitmap_create_with_resource(RESOURCE_ID_STROKE_BUTTERFLY);
    s_icon_stroke_back = gbitmap_create_with_resource(RESOURCE_ID_STROKE_BACK);
    s_icon_stroke_breast = gbitmap_create_with_resource(RESOURCE_ID_STROKE_BREAST);
    s_icon_stroke_freestyle = gbitmap_create_with_resource(RESOURCE_ID_STROKE_FREESTYLE);
    s_icon_default_activity = gbitmap_create_with_resource(RESOURCE_ID_DEFAULT_ACTIVITY);

    s_action_bar_layer = action_bar_layer_create();
    action_bar_layer_set_click_config_provider(s_action_bar_layer, click_config_provider);
    action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_SELECT, s_icon_record);
    action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_UP, s_icon_up);
    action_bar_layer_set_icon(s_action_bar_layer, BUTTON_ID_DOWN, s_icon_down);
    action_bar_layer_add_to_window(s_action_bar_layer, window);

    int16_t width = bounds.size.w - ACTION_BAR_WIDTH;

    s_status_bar = status_bar_layer_create();
    status_bar_layer_set_colors(s_status_bar, GColorClear, GColorBlack);
    GRect frame = GRect(0, 0, width, STATUS_BAR_LAYER_HEIGHT);
    layer_set_frame(status_bar_layer_get_layer(s_status_bar), frame);
    layer_add_child(window_layer, status_bar_layer_get_layer(s_status_bar));

    s_kit_connection_layer = text_layer_create(GRect(14, STATUS_BAR_LAYER_HEIGHT + 2, width - 28, 14));
    text_layer_set_font(s_kit_connection_layer, fonts_get_system_font(FONT_KEY_GOTHIC_14));
    layer_add_child(window_layer, text_layer_get_layer(s_kit_connection_layer));

    s_stopwatch_layer = text_layer_create(GRect(0, STATUS_BAR_LAYER_HEIGHT + 14, width, 32));
    text_layer_set_font(s_stopwatch_layer, fonts_get_system_font(FONT_KEY_LECO_32_BOLD_NUMBERS));
    text_layer_set_background_color(s_stopwatch_layer, GColorClear);
    text_layer_set_text_color(s_stopwatch_layer, GColorBlack);
    text_layer_set_text_alignment(s_stopwatch_layer, GTextAlignmentCenter);
    text_layer_set_text(s_stopwatch_layer, "00:00");
    layer_add_child(window_layer, text_layer_get_layer(s_stopwatch_layer));

    s_markers_count_layer = text_layer_create(GRect(0, bounds.size.h / 2 - 21, width, 18));
    text_layer_set_font(s_markers_count_layer, fonts_get_system_font(FONT_KEY_GOTHIC_18_BOLD));
    text_layer_set_text_alignment(s_markers_count_layer, GTextAlignmentCenter);
    layer_add_child(window_layer, text_layer_get_layer(s_markers_count_layer));
    text_layer_set_text(s_markers_count_layer, "");

    s_activity_icon_layer = bitmap_layer_create(GRect(14, bounds.size.h / 2 + 12, width - 28, 38));
    bitmap_layer_set_alignment(s_activity_icon_layer, GAlignCenter);
    layer_add_child(window_layer, bitmap_layer_get_layer(s_activity_icon_layer));
    bitmap_layer_set_bitmap(s_activity_icon_layer, activity_icon(activity_type));

    s_activity_label_layer = text_layer_create(GRect(0, bounds.size.h / 2 + 50, width, 36));
    text_layer_set_font(s_activity_label_layer, fonts_get_system_font(FONT_KEY_GOTHIC_18_BOLD));
    text_layer_set_text_alignment(s_activity_label_layer, GTextAlignmentCenter);
    layer_add_child(window_layer, text_layer_get_layer(s_activity_label_layer));
    text_layer_set_text(s_activity_label_layer, activity_label_text(activity_type));


    handle_pebblekit_connection(connection_service_peek_pebblekit_connection());
    connection_service_subscribe((ConnectionHandlers) {
        .pebblekit_connection_handler = handle_pebblekit_connection,
    });


    app_worker_message_subscribe(handle_app_worker_messages);

    AppWorkerMessage msg_data = { .data0 = 0 };
    app_worker_send_message(3, &msg_data);
}

static void window_unload(Window *window) {
    s_icon_stop = NULL;
    s_icon_add_marker = NULL;
    s_icon_record = NULL;
    s_icon_up = NULL;
    s_icon_down = NULL;
    s_icon_stroke_butterfly = NULL;
    s_icon_stroke_back = NULL;
    s_icon_stroke_breast = NULL;
    s_icon_stroke_freestyle = NULL;
    s_icon_default_activity = NULL;

    text_layer_destroy(s_stopwatch_layer);
    text_layer_destroy(s_kit_connection_layer);
    text_layer_destroy(s_activity_label_layer);
    text_layer_destroy(s_markers_count_layer);

    bitmap_layer_destroy(s_activity_icon_layer);

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
