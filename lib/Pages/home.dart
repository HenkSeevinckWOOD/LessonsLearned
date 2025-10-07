import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../LocalStorage/localstorage.dart';
import '../Provider/formstate_management.dart';
import '../Utilities/globalvariables.dart';
import 'SubFunctions/ChatWindow/chatWindow.dart';
import '../Widgets/widgets.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Left sidebar state
  double _sidebarWidth = 50;
  bool _isExpanded = false;

  // Right sidebar state
  double _chatSidebarWidth = 50;
  bool _isChatExpanded = false;

  //Expandable Sidebar
  void _onHover(PointerEvent details) {
    // Left sidebar logic
    if (details.position.dx < 50 && !_isExpanded) {
      setState(() {
        _sidebarWidth = 250;
        _isExpanded = true;
      });
    } else if (details.position.dx > 250 && _isExpanded) {
      setState(() {
        _sidebarWidth = 50;
        _isExpanded = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get Provider Variables Part 1
    final localAppTheme = ResponsiveTheme(context).theme;
    final formStatusProvider = Provider.of<FormStatusProvider>(context, listen: true);
    final isChatVisible = formStatusProvider.chatVisible;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            pageHeader(
              context: context,
              topText: '',
              bottomText: formStatusProvider.pageHeader,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: isChatVisible ? 'Hide Chat' : 'Show Chat',
                icon: Icon(isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline, color: localAppTheme['anchorColors']['primaryColor']),
                onPressed: () {
                  if (isChatVisible) {
                    setState(() {
                      _chatSidebarWidth = 50;
                      _isChatExpanded = false;
                    });
                  }
                },
              ),
            )
          ]),
          Expanded(
            child: MouseRegion(
              onHover: _onHover,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //!! Sidebar
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: _sidebarWidth,
                    decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], border: Border.all(color: localAppTheme['anchorColors']['secondaryColor'])),
                    child: Column(children: [if (!_isExpanded) const Center(child: Icon(Icons.menu, color: Colors.white)) else Expanded(child: formStatusProvider.pageSideWidget)]),
                  ),
                  //!! Main Window
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(border: Border.all(color: localAppTheme['anchorColors']['secondaryColor'])),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'images/WOODProposals.jpg',
                            fit: BoxFit.cover,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: formStatusProvider.pageMainWidget,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //!! Right Chat Sidebar
                  Visibility(
                    visible: isChatVisible,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      width: _chatSidebarWidth,
                      decoration: BoxDecoration(color: localAppTheme['anchorColors']['primaryColor'], border: Border.all(color: localAppTheme['anchorColors']['secondaryColor'])),
                      child: Column(children: [
                        if (!_isChatExpanded)
                          Center(
                              child: IconButton(
                            icon: const Icon(Icons.chat, color: Colors.white),
                            tooltip: 'Open Chat',
                            onPressed: () {
                              formStatusProvider.setChatSessionID('${DateTime.now().toString()}_${LocalStorageService.getUserID()!}');
                              setState(() {
                                _chatSidebarWidth = 300;
                                _isChatExpanded = true;
                              });
                            },
                          ))
                        else
                          Expanded(
                            child: ChatWindow(
                              onClose: () {
                                setState(() {
                                  _chatSidebarWidth = 50;
                                  _isChatExpanded = false;
                                });
                              },
                            ),
                          )
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          pageFooter(context: context, userRole: ''),
        ],
      ),
    );
  }
}
