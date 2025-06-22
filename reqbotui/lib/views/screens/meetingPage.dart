// import 'dart:developer';

// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';

// class MeetingPage extends StatefulWidget {
//   final String userName;

//   const MeetingPage({super.key, required this.userName});

//   @override
//   State<MeetingPage> createState() => _MeetingPageState();
// }

// class _MeetingPageState extends State<MeetingPage>
//     implements HMSUpdateListener, HMSActionResultListener {
//   late final HMSSDK hmsSDK;
//   late final String userName;
//   final String roomCode = "cyv-mbcx-rhm";

//   HMSPeer? localPeer, remotePeer;
//   HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;

//   bool isMicMuted = false;
//   bool displayMicrophoneButton = true;
//   bool isRecording = false;

//   @override
//   void initState() {
//     super.initState();
//     userName = widget.userName;
//     _initializeHMSSDK();
//   }

//   Future<void> _initializeHMSSDK() async {
//     hmsSDK = HMSSDK();
//     await hmsSDK.build();
//     hmsSDK.addUpdateListener(listener: this);

//     final String? authToken = await hmsSDK.getAuthTokenByRoomCode(
//       roomCode: roomCode,
//     );
//     if (authToken != null) {
//       await hmsSDK.join(
//         config: HMSConfig(authToken: authToken, userName: userName),
//       );
//     } else {
//       log("Failed to get auth token");
//     }
//   }

//   @override
//   void dispose() {
//     hmsSDK.removeUpdateListener(listener: this);
//     hmsSDK.leave();
//     super.dispose();
//   }

//   void _toggleRecording() {
//     if (!isRecording) {
//       final config = HMSRecordingConfig(
//         toRecord: true,
//         rtmpUrls: [],
//         meetingUrl: "",
//         resolution: HMSResolution(height: 720, width: 1280),
//       );
//       hmsSDK.startRtmpOrRecording(
//         hmsRecordingConfig: config,
//         hmsActionResultListener: this,
//       );
//     } else {
//       hmsSDK.stopRtmpAndRecording(hmsActionResultListener: this);
//     }
//   }

//   @override
//   void onJoin({required HMSRoom room}) {
//     for (var peer in room.peers ?? []) {
//       if (peer.isLocal) {
//         localPeer = peer;
//         localPeerVideoTrack = peer.videoTrack;
//       }
//     }
//     setState(() {
//       isRecording = room.hmsBrowserRecordingState?.running ?? false;
//     });
//   }

//   @override
//   void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
//     setState(() {
//       isRecording = room.hmsBrowserRecordingState?.running ?? false;
//     });
//   }

//   @override
//   void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
//     setState(() {
//       if (!peer.isLocal) {
//         if (update == HMSPeerUpdate.peerLeft) {
//           remotePeer = null;
//         } else {
//           remotePeer = peer;
//         }
//       }
//     });
//   }

//   @override
//   void onTrackUpdate({
//     required HMSTrack track,
//     required HMSTrackUpdate trackUpdate,
//     required HMSPeer peer,
//   }) {
//     if (peer.isLocal) {
//       if (track.kind == HMSTrackKind.kHMSTrackKindAudio &&
//           track.source == "REGULAR") {
//         setState(() {
//           isMicMuted = track.isMute;
//         });
//         log(track.isMute ? "Mic muted" : "Mic unmuted");
//       }

//       displayMicrophoneButton =
//           peer.role.publishSettings?.allowed.contains("audio") ?? false;
//     }

//     if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
//       setState(() {
//         if (trackUpdate == HMSTrackUpdate.trackRemoved) {
//           if (peer.isLocal) {
//             localPeerVideoTrack = null;
//           } else {
//             remotePeerVideoTrack = null;
//           }
//         } else {
//           if (peer.isLocal) {
//             localPeerVideoTrack = track as HMSVideoTrack;
//           } else {
//             remotePeerVideoTrack = track as HMSVideoTrack;
//           }
//         }
//       });
//     }
//   }

//   Widget _buildControlButton({
//     required IconData icon,
//     required Color? color,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: CircleAvatar(
//         radius: 24,
//         backgroundColor: color ?? Colors.grey,
//         child: Icon(icon, color: Colors.white, size: 20),
//       ),
//     );
//   }

//   Widget _buildPeerTile(HMSVideoTrack? videoTrack, HMSPeer? peer) {
//     //   return Container(
//     //     decoration: BoxDecoration(
//     //       borderRadius: BorderRadius.circular(12),
//     //       color: Colors.grey[200],
//     //     ),
//     //     margin: const EdgeInsets.symmetric(vertical: 8),
//     //     child: (videoTrack != null && !videoTrack.isMute)
//     //         ? ClipRRect(
//     //             borderRadius: BorderRadius.circular(12),
//     //             child: HMSVideoView(track: videoTrack),
//     //           )
//     //         : Center(
//     //             child: Container(
//     //               decoration: BoxDecoration(
//     //                 shape: BoxShape.circle,
//     //                 color: Colors.blue[100],
//     //               ),
//     //               padding: const EdgeInsets.all(24),
//     //               child: Text(
//     //                 peer?.name.substring(0, 1).toUpperCase() ?? "U",
//     //                 style: const TextStyle(fontSize: 28, color: Colors.black87),
//     //               ),
//     //             ),
//     //           ),
//     //   );
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: (videoTrack != null && !videoTrack.isMute)
//           ? ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: HMSVideoView(track: videoTrack),
//             )
//           : Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.person, size: 48, color: Colors.blueAccent),
//                 const SizedBox(height: 8),
//                 Text(
//                   peer?.name ?? "User",
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await hmsSDK.leave();
//         Navigator.pop(context);
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor:
//             const Color(0xFFF8F9FA), // Soft light gray for consistency
//         // backgroundColor: Colors.white,
//         body: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "Live Meeting",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             GridView(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 1,
//                 mainAxisSpacing: 8,
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//               children: [
//                 if (remotePeer != null)
//                   _buildPeerTile(remotePeerVideoTrack, remotePeer),
//                 if (localPeer != null)
//                   _buildPeerTile(localPeerVideoTrack, localPeer),
//               ],
//             ),
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 8,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (displayMicrophoneButton)
//                         _buildControlButton(
//                           icon: isMicMuted ? Icons.mic_off : Icons.mic,
//                           color: Colors.grey[700],
//                           onTap: () async {
//                             await hmsSDK.toggleMicMuteState();
//                           },
//                         ),
//                       const SizedBox(width: 20),
//                       _buildControlButton(
//                         icon: isRecording
//                             ? Icons.stop
//                             : Icons.fiber_manual_record,
//                         color: isRecording ? Colors.green : Colors.grey[700],
//                         onTap: _toggleRecording,
//                       ),
//                       const SizedBox(width: 20),
//                       _buildControlButton(
//                         icon: Icons.call_end,
//                         color: Colors.red,
//                         onTap: () async {
//                           await hmsSDK.leave();
//                           Navigator.pop(context);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void onSuccess({
//     HMSActionResultListenerMethod methodType =
//         HMSActionResultListenerMethod.unknown,
//     Map<String, dynamic>? arguments,
//   }) {
//     log("Success: $methodType");
//   }

//   @override
//   void onException({
//     HMSActionResultListenerMethod methodType =
//         HMSActionResultListenerMethod.unknown,
//     Map<String, dynamic>? arguments,
//     required HMSException hmsException,
//   }) {
//     log("Exception: $methodType, error: ${hmsException.message}");
//   }

//   @override
//   void onHMSError({required HMSException error}) {}
//   @override
//   void onAudioDeviceChanged({
//     HMSAudioDevice? currentAudioDevice,
//     List<HMSAudioDevice>? availableAudioDevice,
//   }) {}
//   @override
//   void onChangeTrackStateRequest({
//     required HMSTrackChangeRequest hmsTrackChangeRequest,
//   }) {}
//   @override
//   void onMessage({required HMSMessage message}) {}
//   @override
//   void onReconnected() {}
//   @override
//   void onReconnecting() {}
//   @override
//   void onRemovedFromRoom({
//     required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
//   }) {}
//   @override
//   void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}
//   @override
//   void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
//   @override
//   void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}
//   @override
//   void onPeerListUpdate({
//     required List<HMSPeer> addedPeers,
//     required List<HMSPeer> removedPeers,
//   }) {}
// }

import 'dart:developer';
// import 'email_db_helper.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:reqbot/views/screens/choose_action_screen.dart';

class MeetingPage extends StatefulWidget {
  final String userName;

  const MeetingPage({super.key, required this.userName});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener, HMSActionResultListener {
  late final HMSSDK hmsSDK;
  late final String userName;
  final String roomCode = "cyv-mbcx-rhm";

  HMSPeer? localPeer, remotePeer;
  HMSVideoTrack? localPeerVideoTrack, remotePeerVideoTrack;

  bool isMicMuted = false;
  bool displayMicrophoneButton = true;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    _initializeHMSSDK();
  }

  Future<void> _initializeHMSSDK() async {
    hmsSDK = HMSSDK();
    await hmsSDK.build();
    hmsSDK.addUpdateListener(listener: this);

    final String? authToken =
        await hmsSDK.getAuthTokenByRoomCode(roomCode: roomCode);
    if (authToken != null) {
      await hmsSDK.join(
        config: HMSConfig(authToken: authToken, userName: userName),
      );
    } else {
      log("Failed to get auth token");
    }
  }

  @override
  void dispose() {
    hmsSDK.removeUpdateListener(listener: this);
    hmsSDK.leave();
    super.dispose();
  }

  void _toggleRecording() {
    if (!isRecording) {
      final config = HMSRecordingConfig(
        toRecord: true,
        rtmpUrls: [],
        meetingUrl: "",
        resolution: HMSResolution(height: 720, width: 1280),
      );
      hmsSDK.startRtmpOrRecording(
        hmsRecordingConfig: config,
        hmsActionResultListener: this,
      );
    } else {
      hmsSDK.stopRtmpAndRecording(hmsActionResultListener: this);
    }
  }

  @override
  void onJoin({required HMSRoom room}) {
    for (var peer in room.peers ?? []) {
      if (peer.isLocal) {
        localPeer = peer;
        localPeerVideoTrack = peer.videoTrack;
      }
    }
    setState(() {
      isRecording = room.hmsBrowserRecordingState?.running ?? false;
    });
  }

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {
    setState(() {
      isRecording = room.hmsBrowserRecordingState?.running ?? false;
    });
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    setState(() {
      if (!peer.isLocal) {
        if (update == HMSPeerUpdate.peerLeft) {
          remotePeer = null;
        } else {
          remotePeer = peer;
        }
      }
    });
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    if (peer.isLocal) {
      if (track.kind == HMSTrackKind.kHMSTrackKindAudio &&
          track.source == "REGULAR") {
        setState(() {
          isMicMuted = track.isMute;
        });
        log(track.isMute ? "Mic muted" : "Mic unmuted");
      }

      displayMicrophoneButton =
          peer.role.publishSettings?.allowed.contains("audio") ?? false;
    }

    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      setState(() {
        if (trackUpdate == HMSTrackUpdate.trackRemoved) {
          if (peer.isLocal) {
            localPeerVideoTrack = null;
          } else {
            remotePeerVideoTrack = null;
          }
        } else {
          if (peer.isLocal) {
            localPeerVideoTrack = track as HMSVideoTrack;
          } else {
            remotePeerVideoTrack = track as HMSVideoTrack;
          }
        }
      });
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: color ?? Colors.grey,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildPeerTile(HMSVideoTrack? videoTrack, HMSPeer? peer) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: (videoTrack != null && !videoTrack.isMute)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: HMSVideoView(track: videoTrack),
            )
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[100],
                ),
                padding: const EdgeInsets.all(24),
                child: Text(
                  peer?.name.substring(0, 1).toUpperCase() ?? "U",
                  style: const TextStyle(fontSize: 28, color: Colors.black87),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await hmsSDK.leave();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              children: [
                if (remotePeer != null)
                  _buildPeerTile(remotePeerVideoTrack, remotePeer),
                if (localPeer != null)
                  _buildPeerTile(localPeerVideoTrack, localPeer),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayMicrophoneButton)
                        _buildControlButton(
                          icon: isMicMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.grey[700],
                          onTap: () async {
                            await hmsSDK.toggleMicMuteState();
                          },
                        ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: isRecording
                            ? Icons.stop
                            : Icons.fiber_manual_record,
                        color: isRecording ? Colors.green : Colors.grey[700],
                        onTap: _toggleRecording,
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: Icons.call_end,
                        color: Colors.red,
                        onTap: () async {
                          await hmsSDK.leave();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChooseActionScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onSuccess({
    HMSActionResultListenerMethod methodType =
        HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
  }) {
    log("Success: $methodType");
  }

  @override
  void onException({
    HMSActionResultListenerMethod methodType =
        HMSActionResultListenerMethod.unknown,
    Map<String, dynamic>? arguments,
    required HMSException hmsException,
  }) {
    log("Exception: $methodType, error: ${hmsException.message}");
  }

  @override
  void onHMSError({required HMSException error}) {}
  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}
  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}
  @override
  void onMessage({required HMSMessage message}) {}
  @override
  void onReconnected() {}
  @override
  void onReconnecting() {}
  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}
  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}
  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}
  @override
  void onPeerListUpdate({
    required List<HMSPeer> addedPeers,
    required List<HMSPeer> removedPeers,
  }) {}
}
