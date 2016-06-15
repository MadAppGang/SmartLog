#include <pebble.h>

#include "modules/app_messenger.h"

#include "windows/main_window.h" // REMOVE

// static const int inbox_size = 32;
// static const int outbox_size = 256;
//
// static void inbox_received_callback(DictionaryIterator *iter, void *context) {
//     show_info_string("PING");
// }
//
// static void inbox_dropped_callback(AppMessageResult reason, void *context) {
//     show_info_string("PING FAILED");
// }
//
// static void outbox_sent_callback(DictionaryIterator *iter, void *context) {
//     show_info_string("SUCCESS");
// }
//
// static void outbox_failed_callback(DictionaryIterator *iter, AppMessageResult reason, void *context) {
//     static char reasonStr[20];
//
//     switch(reason){
//         case APP_MSG_OK:
//         snprintf(reasonStr,20,"%s","APP_MSG_OK");
//         break;
//         case APP_MSG_SEND_TIMEOUT:
//         snprintf(reasonStr,20,"%s","SEND TIMEOUT");
//         break;
//         case APP_MSG_SEND_REJECTED:
//         snprintf(reasonStr,20,"%s","SEND REJECTED");
//         break;
//         case APP_MSG_NOT_CONNECTED:
//         snprintf(reasonStr,20,"%s","NOT CONNECTED");
//         break;
//         case APP_MSG_APP_NOT_RUNNING:
//         snprintf(reasonStr,20,"%s","NOT RUNNING");
//         break;
//         case APP_MSG_INVALID_ARGS:
//         snprintf(reasonStr,20,"%s","INVALID ARGS");
//         break;
//         case APP_MSG_BUSY:
//         snprintf(reasonStr,20,"%s","BUSY");
//         break;
//         case APP_MSG_BUFFER_OVERFLOW:
//         snprintf(reasonStr,20,"%s","BUFFER OVERFLOW");
//         break;
//         case APP_MSG_ALREADY_RELEASED:
//         snprintf(reasonStr,20,"%s","ALRDY RELEASED");
//         break;
//         case APP_MSG_CALLBACK_ALREADY_REGISTERED:
//         snprintf(reasonStr,20,"%s","CLB ALR REG");
//         break;
//         case APP_MSG_CALLBACK_NOT_REGISTERED:
//         snprintf(reasonStr,20,"%s","CLB NOT REG");
//         break;
//         case APP_MSG_OUT_OF_MEMORY:
//         snprintf(reasonStr,20,"%s","OUT OF MEM");
//         break;
//         case APP_MSG_CLOSED:
//         snprintf(reasonStr,20,"%s","MSG CLOSED");
//         break;
//         case APP_MSG_INTERNAL_ERROR:
//         snprintf(reasonStr,20,"%s","INTERNAL ERROR");
//         break;
//         case APP_MSG_INVALID_STATE:
//         snprintf(reasonStr,20,"%s","INVALID STATE");
//         break;
//     }
//
//     show_info_string(reasonStr);
// }
//
// void app_messenger_init() {
//     app_message_register_inbox_received(inbox_received_callback);
//     app_message_register_inbox_dropped(inbox_dropped_callback);
//     app_message_register_outbox_sent(outbox_sent_callback);
//     app_message_register_outbox_failed(outbox_failed_callback);
//
//     app_message_open(inbox_size, outbox_size);
// }
//
// void app_messenger_send_string() {
//     DictionaryIterator *out_iter;
//     AppMessageResult result = app_message_outbox_begin(&out_iter);
//
//     if(result != APP_MSG_OK) {
//         return;
//     }
//
//     dict_write_cstring(out_iter, 0, "ping");
//
//     app_message_outbox_send();
//     show_info_string("pink");
// }
