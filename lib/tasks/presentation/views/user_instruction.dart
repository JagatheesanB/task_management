import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserInstructionsPage extends StatefulWidget {
  const UserInstructionsPage({Key? key}) : super(key: key);

  @override
  State<UserInstructionsPage> createState() => _UserInstructionsPageState();
}

class _UserInstructionsPageState extends State<UserInstructionsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.userInstructions,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.addTaskInstruction,
              Icons.add,
              Colors.green,
              0,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.editTaskInstruction,
              Icons.edit,
              Colors.orange,
              1,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.deleteTaskInstruction,
              Icons.delete,
              Colors.red,
              2,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.addNoteInstruction,
              Icons.note_add,
              Colors.blue,
              3,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.completeTaskInstruction,
              Icons.done_all,
              Colors.green,
              4,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.uncompleteTaskInstruction,
              Icons.more_vert,
              Colors.grey,
              5,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.taskReportsInstruction,
              Icons.info,
              Colors.blue,
              6,
            ),
            const SizedBox(
              height: 8,
            ),
            _buildAnimatedInstructionItem(
              context,
              AppLocalizations.of(context)!.viewHistoryInstruction,
              Icons.history,
              Colors.purple,
              7,
            ),
            const SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedInstructionItem(BuildContext context, String text,
      IconData icon, Color color, int index) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _buildInstructionItem(context, text, icon, color),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
      BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28.0,
            color: color,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

// class UserInstructionsPage extends StatefulWidget {
//   const UserInstructionsPage({Key? key}) : super(key: key);

//   @override
//   _UserInstructionsPageState createState() => _UserInstructionsPageState();
// }

// class _UserInstructionsPageState extends State<UserInstructionsPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<double> _scaleAnimation;
//   List<TargetFocus> targets = [];

//   final GlobalKey addTaskKey = GlobalKey();
//   final GlobalKey editTaskKey = GlobalKey();
//   final GlobalKey deleteTaskKey = GlobalKey();
//   final GlobalKey addNoteKey = GlobalKey();
//   final GlobalKey completeTaskKey = GlobalKey();
//   final GlobalKey uncompleteTaskKey = GlobalKey();
//   final GlobalKey taskReportsKey = GlobalKey();
//   final GlobalKey viewHistoryKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeIn,
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.elasticOut,
//       ),
//     );

//     _controller.forward();

//     WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _afterLayout(_) {
//     _initTargets();
//     _showTutorial();
//   }

//   void _initTargets() {
//     targets.addAll([
//       _createTarget(
//           addTaskKey, AppLocalizations.of(context)!.addTaskInstruction),
//       _createTarget(
//           editTaskKey, AppLocalizations.of(context)!.editTaskInstruction),
//       _createTarget(
//           deleteTaskKey, AppLocalizations.of(context)!.deleteTaskInstruction),
//       _createTarget(
//           addNoteKey, AppLocalizations.of(context)!.addNoteInstruction),
//       _createTarget(completeTaskKey,
//           AppLocalizations.of(context)!.completeTaskInstruction),
//       _createTarget(uncompleteTaskKey,
//           AppLocalizations.of(context)!.uncompleteTaskInstruction),
//       _createTarget(
//           taskReportsKey, AppLocalizations.of(context)!.taskReportsInstruction),
//       _createTarget(
//           viewHistoryKey, AppLocalizations.of(context)!.viewHistoryInstruction),
//     ]);
//   }

//   void _showTutorial() {
//     TutorialCoachMark(
//       targets: targets,
//       colorShadow: Colors.black,
//       textSkip: 'skip',
//       paddingFocus: 10,
//       opacityShadow: 0.8,
//       onFinish: () {
//         print('Tutorial finished');
//       },
//       onSkip: () {
//         print('Tutorial skipped');
//         return false;
//       },
//       onClickTarget: (target) {
//         print('Target clicked: $target');
//       },
//     ).show(context: context);
//   }

//   TargetFocus _createTarget(GlobalKey key, String description) {
//     return TargetFocus(
//       identify: key.toString(),
//       keyTarget: key,
//       contents: [
//         TargetContent(
//           align: ContentAlign.bottom,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(
//               description,
//               style: const TextStyle(color: Colors.white, fontSize: 20),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           AppLocalizations.of(context)!.userInstructions,
//           style: const TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.addTaskInstruction,
//               Icons.add,
//               Colors.green,
//               addTaskKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.editTaskInstruction,
//               Icons.edit,
//               Colors.orange,
//               editTaskKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.deleteTaskInstruction,
//               Icons.delete,
//               Colors.red,
//               deleteTaskKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.addNoteInstruction,
//               Icons.note_add,
//               Colors.blue,
//               addNoteKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.completeTaskInstruction,
//               Icons.done_all,
//               Colors.green,
//               completeTaskKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.uncompleteTaskInstruction,
//               Icons.more_vert,
//               Colors.grey,
//               uncompleteTaskKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.taskReportsInstruction,
//               Icons.info,
//               Colors.blue,
//               taskReportsKey,
//             ),
//             _buildAnimatedInstructionItem(
//               context,
//               AppLocalizations.of(context)!.viewHistoryInstruction,
//               Icons.history,
//               Colors.purple,
//               viewHistoryKey,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAnimatedInstructionItem(BuildContext context, String text,
//       IconData icon, Color color, GlobalKey key) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: _buildInstructionItem(context, text, icon, color, key),
//         ),
//       ),
//     );
//   }

//   Widget _buildInstructionItem(BuildContext context, String text, IconData icon,
//       Color color, GlobalKey key) {
//     return Container(
//       key: key,
//       padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//       margin: const EdgeInsets.only(bottom: 16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8.0),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(
//             icon,
//             size: 28.0,
//             color: color,
//           ),
//           const SizedBox(width: 16.0),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 16.0,
//                 fontWeight: FontWeight.normal,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
