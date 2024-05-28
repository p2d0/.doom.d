;;; nixos/editors/.doom.d/package_configuration/telega/tests/test_telega.el -*- lexical-binding: t; -*-

(describe "sticker"
  (it "should send to thread"
    (let* ((msg '(:@type "message" :id 45884637184 :sender_id (:@type "messageSenderUser" :user_id 98910262) :chat_id -1001607382841 :is_outgoing t :is_pinned nil :is_from_offline nil :can_be_edited t :can_be_forwarded t :can_be_replied_in_another_chat t :can_be_saved t :can_be_deleted_only_for_self nil :can_be_deleted_for_all_users t :can_get_added_reactions nil :can_get_statistics nil :can_get_message_thread nil :can_get_read_date nil :can_get_viewers t :can_get_media_timestamp_links t :can_report_reactions nil :has_timestamped_media t :is_channel_post nil :is_topic_message t :contains_unread_mention nil :date 1716901713 :edit_date 0 :unread_reactions [] :message_thread_id 31457280 :saved_messages_topic_id 0 :self_destruct_in 0.0 :auto_delete_in 0.0 :via_bot_user_id 0 :sender_business_bot_user_id 0 :sender_boost_count 0 :author_signature "" :media_album_id "0" :restriction_reason "" :content (:@type "messageText" :text (:@type "formattedText" :text "Kappa" :entities [])) :ignored-p nil)))
      (spy-on 'send-sticker :and-call-fake (lambda (stick chat)
					     (expect (plist-get chat :message_thread_id) :not :to-equal 0)
					     (expect (telega-chat-message-thread-id
						       chat nil 'for-send) :not :to-equal 0)
					     ))
      (telega-if-kappa-send-sticker msg)
      (expect 'send-sticker :to-have-been-called)
      )
    ))
