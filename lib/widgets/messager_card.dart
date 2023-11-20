import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatup/api/apis.dart';
import 'package:chatup/model/messages.dart';
import 'package:chatup/utils/mydate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class MessagerCard extends StatefulWidget {
  const MessagerCard({super.key, required this.message});

  final Messages message;

  @override
  State<MessagerCard> createState() => _MessagerCardState();
}

class _MessagerCardState extends State<MessagerCard> {
  bool isLastMessageRead = false;

  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return GestureDetector(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? greenMessage() : blueMessage());
  }

  Widget blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMesageReadStatus(widget.message);
    }
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: const Color(0xffe7e7e7),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.only(top: 10, left: 15, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.message.type == Type.text
                  ? SizedBox(
                      width: widget.message.msg.toString().length > 25
                          ? 270
                          : null,
                      child: Text(
                        widget.message.msg,
                        style: const TextStyle(fontSize: 15),
                      ))
                  : Image.network(
                      widget.message.msg,
                      width: MediaQuery.of(context).size.width - 200,
                    ),
              const SizedBox(
                height: 10,
              ),
              Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 12, color: Colors.black)),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget greenMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: const Color(0xff8efc6f),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              widget.message.type == Type.text
                  ? SizedBox(
                      width: widget.message.msg.toString().length > 25
                          ? 270
                          : null,
                      child: Text(
                        widget.message.msg,
                        style: const TextStyle(fontSize: 15),
                      ))
                  : SizedBox(
                      width: MediaQuery.of(context).size.width - 200,
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
              const SizedBox(
                height: 5,
              ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.withOpacity(.6),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 5,
                ),
                if (widget.message.read.isNotEmpty)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text('Received', style: TextStyle(color: Colors.white)),
                    ],
                  )
                else
                  const Text('Sent', style: TextStyle(color: Colors.white)),
              ],
            )),
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        context: context,
        builder: (context) {
          return  SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(20),
                    height: 4,
                    width: 50,
                    color: Colors.grey,
                  ),
                  widget.message.type == Type.text
                      ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                            ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          EasyLoading.showToast( 'Text Copied!');
                        });
                      })
                      :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          FileDownloader.downloadFile(
                            url: widget.message.msg,
                            name: "logo.png",
                            onProgress: (fileName, progress) {
                              setState(() {
                              });
                              // updateNotificationProgress(progress);
                            },
                            onDownloadCompleted: (path) {
                              setState(() {
                                EasyLoading.showSuccess("Saved image $path successfully");
                                // _notificationsPlugin.cancel(0);
                              });
                            },
                            onDownloadError: (path) {
                              setState(() {
                                EasyLoading.showError("Saved image $path failed");
                                // _notificationsPlugin.cancel(0);
                              });
                            },
                          );
                        } catch (e) {
                          print('ErrorWhileSavingImg: $e');
                        }
                      }),

                  //separator or divider
                  if (isMe)
                    Divider(
                      color: Colors.black54,
                      endIndent: 2,
                      indent: 2,
                    ),
                  if (isMe)
                    _OptionItem(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.red, size: 26),
                        name: 'Delete Message',
                        onTap: () async {
                          await APIs.deleteMessage(widget.message).then((value) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                          });
                        }),

                  //separator or divider
                  Divider(
                    color: Colors.black54,
                    endIndent: 2,
                    indent: 2,
                  ),

                  //sent time
                  _OptionItem(
                      icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                      name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                      onTap: () {}),

                  //read time
                  _OptionItem(
                      icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                      name: widget.message.read.isEmpty
                          ? 'Read At: Not seen yet'
                          : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                      onTap: () {}),
                ],
              ),
          );
        });

  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 12, bottom: 10),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('$name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }

}
