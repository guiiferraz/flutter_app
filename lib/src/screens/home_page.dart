import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];

  final TextEditingController _taskController = TextEditingController();

  void _toggleTaskDeleted(Map<String, dynamic> task) {
    setState(() {
      task["deleted"] = !(task["deleted"] ?? false);
    });
  }

  void _addTask() {
    String selectedDate = '';
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            "Nova Tarefa",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: "Digite sua tarefa",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF2A2A2A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB388FF), width: 2),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFB388FF),
                            onPrimary: Colors.black,
                            surface: Color(0xFF1E1E1E),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setDialogState(() {
                      selectedDate = "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFFB388FF)),
                      const SizedBox(width: 12),
                      Text(
                        selectedDate.isEmpty ? "Selecionar data" : selectedDate,
                        style: TextStyle(
                          color: selectedDate.isEmpty ? Colors.grey[600] : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _taskController.clear();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[400],
              ),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  setState(() {
                    tasks.add({
                      "title": _taskController.text,
                      "status": "pending",
                      "deleted": false,
                      "date": selectedDate.isNotEmpty ? selectedDate : null,
                    });
                  });
                  Navigator.pop(dialogContext);
                  _taskController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Adicionar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingTasks =
        tasks.where((task) => task["status"] == "pending").toList();
    final inProgressTasks =
        tasks.where((task) => task["status"] == "in_progress").toList();
    final doneTasks =
        tasks.where((task) => task["status"] == "done").toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      drawer: _buildSideMenu(),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFB388FF)),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        iconTheme: const IconThemeData(
          color: Colors.white,   // coloque a cor que quiser
          size: 28,              // opcional: mudar tamanho
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB388FF),
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text(
          'Nova Tarefa',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: _addTask,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            "Pendentes",
            pendingTasks,
            const Color(0xFFE1BEE7),
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Em Progresso",
            inProgressTasks,
            const Color(0xFFBA68C8),
            Icons.autorenew_rounded,
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Finalizadas",
            doneTasks,
            const Color(0xFF7B1FA2),
            Icons.check_circle_rounded,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSideMenu() {
    return Drawer(
      backgroundColor: const Color(0xFF1E1E1E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildUserHeader(),

          const SizedBox(height: 10),

          _navItem(Icons.person, 'Perfil do Usuário', () {}),
          _navItem(Icons.settings, 'Configurações', () {}),
          _navItem(Icons.info_outline, 'Sobre o App', () {}),

          const Spacer(), // empurra o "Sair" para o final

          const Divider(color: Colors.white24),

          _navItem(Icons.logout, 'Sair', () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFB388FF),
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Usuário",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "email@exemplo.com",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB388FF), size: 26),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, List tasks, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            color: Colors.grey[700],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Nenhuma tarefa aqui",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: tasks.map((task) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 4,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          title: Text(
                            task["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              decoration: task["deleted"] == true
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: Colors.grey,
                              decorationThickness: 2,
                            ),
                          ),
                          subtitle: task["date"] != null
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        task["date"],
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  task["deleted"] == true
                                      ? Icons.refresh_rounded
                                      : Icons.delete_outline_rounded,
                                  color: task["deleted"] == true
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                onPressed: () => _toggleTaskDeleted(task),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                ),
                                color: const Color(0xFF2A2A2A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  setState(() {
                                    task["status"] = value;
                                  });
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: "pending",
                                    child: Row(
                                      children: [
                                        Icon(Icons.schedule_rounded,
                                            color: Color(0xFFE1BEE7), size: 20),
                                        SizedBox(width: 12),
                                        Text(
                                          "Pendentes",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: "in_progress",
                                    child: Row(
                                      children: [
                                        Icon(Icons.autorenew_rounded,
                                            color: Color(0xFFBA68C8), size: 20),
                                        SizedBox(width: 12),
                                        Text(
                                          "Em Progresso",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: "done",
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded,
                                            color: Color(0xFF7B1FA2), size: 20),
                                        SizedBox(width: 12),
                                        Text(
                                          "Finalizadas",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}