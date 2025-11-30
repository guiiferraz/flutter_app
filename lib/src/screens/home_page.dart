import 'package:flutter/material.dart';
import '../data/models/users.dart';
import '../data/repositories/tasks_repository.dart';
import '../data/models/tasks.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  late Usuario currentUser;

  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final TasksRepository tasksRepository = TasksRepository();

  Future<void> loadUserTasks() async {
    final userTasks = await tasksRepository.getTasksByUserId(currentUser.id!);

    setState(() {
      tasks = userTasks.map((t) => {
        "id": t.id,
        "title": t.name,
        "description": t.description,
        "status": t.status,
        "date": t.date,
        "deleted": false,
      }).toList();
    });
  }

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
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Descrição (opcional)",
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
                maxLines: 2,
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
              onPressed: () async {
                if (_taskController.text.isNotEmpty) {

                  final newTask = Tarefa(
                    name: _taskController.text,
                    description: _descriptionController.text,
                    date: selectedDate.isNotEmpty ? selectedDate : "",
                    status: "pending",
                    usuarioId: currentUser.id!,
                  );

                  final newTaskId = await tasksRepository.createTask(newTask);

                  setState(() {
                    tasks.add({
                      "id": newTaskId,
                      "title": _taskController.text,
                      "description": _descriptionController.text,
                      "status": "pending",
                      "deleted": false,
                      "date": selectedDate.isNotEmpty ? selectedDate : "",
                    });
                  });
                  Navigator.pop(dialogContext);
                  _taskController.clear();
                  _descriptionController.clear();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ModalRoute.of(context)?.settings.arguments as Usuario?;
    if (user != null) {
      currentUser = user;
      loadUserTasks();
    }
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
          color: Colors.white,   
          size: 28,              
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
            tasks.where((task) => task["status"] == "pending").toList(),
            const Color(0xFFE1BEE7),
            Icons.schedule_rounded,
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Em Progresso",
            tasks.where((task) => task["status"] == "in_progress").toList(),
            const Color(0xFFBA68C8),
            Icons.autorenew_rounded,
          ),
          const SizedBox(height: 20),
          _buildSection(
            "Finalizadas",
            tasks.where((task) => task["status"] == "done").toList(),
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

          _navItem(Icons.person, 'Perfil do Usuário', () {
            Navigator.pushNamed(
              context,
              '/profile',
              arguments: currentUser,
            );
          }),
          _navItem(Icons.settings, 'Configurações', () {}),
          _navItem(Icons.info_outline, 'Sobre o App', () {
            showDialog(
              context: context,
              builder: (_) => const AboutAppDialog(),
            );
          }),

          const Spacer(),

          const Divider(color: Colors.white24),

          _navItem(Icons.logout, 'Sair', () {
            Navigator.pushReplacementNamed(context, '/login');
          }),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
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
            children: [
              Text(
                currentUser.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentUser.email,
                style: const TextStyle(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        key: ValueKey(task["id"]),
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (task["description"] != null && task["description"]!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    task["description"],
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              if (task["date"] != null && task["date"]!.isNotEmpty)
                                Padding(
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
                                ),
                            ],
                          ),
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
                                onPressed: () async {
                                  final taskId = task["id"];
                                  if (taskId != null) {
                                    await tasksRepository.deleteTask(taskId);
                                    await loadUserTasks();
                                  }
                                },
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
                                onSelected: (value) async {
                                  setState(() {
                                    task["status"] = value;
                                  });

                                  final updatedTask = Tarefa(
                                    id: task["id"],
                                    name: task["title"],
                                    description: task["description"] ?? "",
                                    date: task["date"] ?? "",
                                    status: task["status"],
                                    usuarioId: currentUser.id!,
                                  );

                                  await tasksRepository.updateTask(updatedTask);
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

class AboutAppDialog extends StatelessWidget {
  const AboutAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xFFBA68C8),
              size: 70,
            ),
            const SizedBox(height: 20),

            const Text(
              "Sobre o App",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Este aplicativo foi desenvolvido para gerenciamento de tarefas "
              "com foco em simplicidade, segurança e desempenho. "
              "Conta com autenticação, SQLite local e interface moderna.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Desenvolvido por: Guilherme, Juliana, Vinicíus e Lucas",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),

            const Text(
              "Versão 1.0.0",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Fechar",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
