;; -*- scheme -*-
(stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 981 :coding-system undecided-unix :line 31)) :annotation-list ((annotation :type text :data "ここで説明がある。")) :date "Tue Oct 27 04:13:06 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 2414 :coding-system undecided-unix :line 53 :which-func ("Electric-command-loop"))) :annotation-list ((annotation :type text :data "ここがメイン関数")) :date "Tue Oct 27 04:13:18 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/usr/share/emacs/23.1/lisp/electric.el.gz" :point 5345 :coding-system undecided-unix :line 141 :which-func ("Electric-pop-up-window"))) :annotation-list ((annotation :type text :data "おまけ")) :date "Tue Oct 27 04:13:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 60432 :coding-system undecided-unix :line 2152 :which-func ("totemsrp_mcast"))) :annotation-list ((annotation :type text :data "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")) :date "Mon Nov 16 01:18:35 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 7871 :coding-system undecided-unix :line 276 :surround ("
" "" "struct message_item {
	struct mcast *mcast;") :which-func ("message_item"))) :annotation-list ((annotation :type text :data "message_itemとsort_queue_itemは同じ構造を持つ。")) :date "Mon Nov 16 01:46:22 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemconfig.c" :point 8802 :coding-system undecided-unix :line 297 :surround ("
" "" "	strcpy (totem_config->rrp_mode, \"none\");
") :which-func ("totem_config_read"))) :annotation-list ((annotation :type text :data "active,passive,noneからデフォルトはnone。")) :date "Mon Nov 16 02:16:02 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemudp.c" :point 49674 :coding-system undecided-unix :line 1875 :surround ("
" "" "int totemudp_mcast_noflush_send (
	void *udp_context,") :which-func ("totemudp_mcast_noflush_send"))) :annotation-list ((annotation :type text :data "threadsがonの場合キューに入るが、そうでなければ、totemudp_mcast_flush_sendと同じ。")) :date "Mon Nov 16 02:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 94805 :coding-system undecided-unix :line 3409 :surround ("	case MEMB_STATE_OPERATIONAL:
" "" "		messages_free (instance, token->aru);
	case MEMB_STATE_GATHER:") :which-func ("message_handler_orf_token"))) :annotation-list ((annotation :type text :data "fall through?")) :date "Mon Nov 16 02:29:42 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 99934 :coding-system undecided-unix :line 3569 :surround ("
" "" "			totemrrp_send_flush (instance->totemrrp_context);
			token_send (instance, token, forward_token);") :which-func ("if"))) :annotation-list ((annotation :type text :data "threadを使っている場合、ワークキューが空になるのを待つ。")) :date "Mon Nov 16 02:31:46 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 99987 :coding-system undecided-unix :line 3570 :surround ("			totemrrp_send_flush (instance->totemrrp_context);
" "" "			token_send (instance, token, forward_token);
") :which-func ("if"))) :annotation-list ((annotation :type text :data "次の人にトークンを渡す。")) :date "Mon Nov 16 02:32:23 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 75711 :coding-system undecided-unix :line 2752 :surround ("
" "" "static void memb_state_commit_token_target_set (
	struct totemsrp_instance *instance)") :which-func ("memb_state_commit_token_target_set"))) :annotation-list ((annotation :type text :data "トークンを受けとる人一覧をセットしている？")) :date "Mon Nov 16 02:35:32 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 75914 :coding-system undecided-unix :line 2760 :surround ("
" "" "	for (i = 0; i < instance->totem_config->interface_count; i++) {
		totemrrp_token_target_set (") :which-func ("memb_state_commit_token_target_set"))) :annotation-list ((annotation :type text :data "interfaceでループ")) :date "Mon Nov 16 02:48:13 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 14495 :coding-system undecided-unix :line 580 :surround ("{
" "" "	totemnet_token_target_set (instance->net_handles[0], token_target);
}") :which-func ("none_token_target_set"))) :annotation-list ((annotation :type text :data "interfaceを引数に渡しているが、使っていない。single ring?")) :date "Mon Nov 16 02:48:57 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 23893 :coding-system undecided-unix :line 922 :surround ("
" "" "static void passive_token_target_set (
	struct totemrrp_instance *instance,") :which-func ("passive_token_target_set"))) :annotation-list ((annotation :type text :data "activeでもpassiveでも同じ。各インターフェイス毎に処理している。")) :date "Mon Nov 16 02:50:11 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 27162 :coding-system undecided-unix :line 1080 :surround ("                if (quorum_device->state == NODESTATE_DEAD) {
" "" "                        quorum_device->state = NODESTATE_MEMBER;
                        recalculate_quorum(0, 0);") :which-func ("do_cmd_poll_quorum_device"))) :annotation-list ((annotation :type text :data "quorum deviceを1ノードとみなしてメンバーにている。")) :date "Wed Nov 18 02:33:47 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 24651 :coding-system undecided-unix :line 1016 :surround ("			if (!errors)
" "" "				cman_poll_quorum_device(ctx->qc_ch, 1);
") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "ここでquorumデバイスがあたかもノードとして与えられたvoteを維持。")) :date "Wed Nov 18 02:38:25 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "???")) :date "Wed Nov 18 02:39:26 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 21604 :coding-system undecided-unix :line 903 :surround ("				} else {
" "" "					cman_poll_quorum_device(ctx->qc_ch, 0);
				}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "quorumデバイスのvoteを破棄")) :date "Wed Nov 18 02:40:03 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7491 :coding-system undecided-unix :line 288 :surround ("
" "" "	list_iterate(nodelist, &cluster_members_list) {
		node = list_item(nodelist, struct cluster_node);") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "参加しているノード全員のvotesの和を計算(total_votes)
参加しているノード全員のexpected votesのうち最大のものを求める(highest_expected)")) :date "Wed Nov 18 02:43:09 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7760 :coding-system undecided-unix :line 298 :surround ("	}
" "" "	if (quorum_device && quorum_device->state == NODESTATE_MEMBER)
		total_votes += quorum_device->votes;") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "quorum_deviceが有効であれば、それに与えられているvoteを加算")) :date "Wed Nov 18 02:44:21 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "これだと masterでもmasterでなくともvoteをかせげる。")) :date "Wed Nov 18 11:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 32464 :coding-system undecided-unix :line 1285 :surround ("	case CMAN_CMD_ISQUORATE:
" "" "		return cluster_is_quorate;
") :which-func ("process_command"))) :annotation-list ((annotation :type text :data "この変数を見ればquorateかどうかわかる。")) :date "Wed Nov 18 11:20:06 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/lib/libcman.h" :point 2306 :coding-system undecided-unix :line 62 :surround ("typedef enum {CMAN_REASON_PORTCLOSED,
" "" "	      CMAN_REASON_STATECHANGE,
              CMAN_REASON_PORTOPENED,")) (target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/cnxman-socket.h" :point 4173 :coding-system undecided-unix :line 104 :surround ("#define EVENT_REASON_PORTCLOSED   0
" "" "#define EVENT_REASON_STATECHANGE  1
#define EVENT_REASON_PORTOPENED   2"))) :annotation-list ((annotation :type text :data "CMAN_REASON_STATECHANGE == EVENT_REASON_STATECHANGE")) :date "Wed Nov 18 12:03:31 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/group/daemon/cman.c" :point 3171 :coding-system undecided-unix :line 129 :surround ("		break;
" "" "	case CMAN_REASON_STATECHANGE:
		statechange();") :which-func ("cman_callback"))) :annotation-list ((annotation :type text :data "cman daemonのrecalculate_quorumから来る。")) :date "Wed Nov 18 12:05:46 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
