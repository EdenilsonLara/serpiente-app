import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'perfil.dart';

class SnakeGame extends StatefulWidget {
  final Perfil perfil;
  final ApiService apiService = ApiService();

  SnakeGame({required this.perfil});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const int speed = 100;
  static const List<List<int>> directions = [
    [0, -1], // Up
    [0, 1], // Down
    [-1, 0], // Left
    [1, 0], // Right
  ];

  List<List<int>> snake = [
    [10, 10],
    [10, 11],
    [10, 12],
  ];
  List<int> food = [0, 0];
  int directionIndex = 3;
  bool isPlaying = true;
  bool isPaused = false;
  int ballsEaten = 0;
  Timer? _timer;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    newFood();
    _startGameTimer();
  }

  void _startGameTimer() {
    _timer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (isPlaying && !isPaused) {
        moveSnake();
      } else if (!isPlaying) {
        timer.cancel();
        gameOver();
      }
    });
  }

  void newFood() {
    final random = Random();
    setState(() {
      food = [random.nextInt(gridSize), random.nextInt(gridSize)];
    });
  }

  void moveSnake() {
    setState(() {
      final List<int> nextPosition = [
        (snake.first[0] + directions[directionIndex][0]) % gridSize,
        (snake.first[1] + directions[directionIndex][1]) % gridSize,
      ];

      if (nextPosition.contains(-1) ||
          snake.any((pos) =>
              pos[0] == nextPosition[0] && pos[1] == nextPosition[1])) {
        isPlaying = false;
        return;
      }

      snake.insert(0, nextPosition);

      if (nextPosition[0] == food[0] && nextPosition[1] == food[1]) {
        newFood();
        ballsEaten++;

        if (ballsEaten > widget.perfil.record) {
          apiService
              .updateRecord(widget.perfil.id, ballsEaten)
              .catchError((error) {
            print('Error al actualizar el record: $error');
          });
        }
      } else {
        snake.removeLast();
      }
    });
  }

  void gameOver() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            title: Text('Game Over'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('¿Quieres jugar de nuevo?'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      snake = [
                        [10, 10],
                        [10, 11],
                        [10, 12],
                      ];
                      newFood();
                      isPlaying = true;
                      ballsEaten = 0;
                      isPaused = false;
                    });
                    Navigator.of(context).pop();
                    _startGameTimer();
                  },
                  child: Text('Sí, iniciar juego'),
                ),
              ],
            ),
            actions: <Widget>[],
          ),
        );
      },
    );
  }

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  void restartGame() {
    setState(() {
      snake = [
        [10, 10],
        [10, 11],
        [10, 12],
      ];
      newFood();
      isPlaying = true;
      ballsEaten = 0;
    });
    isPaused = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Game'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        color: Colors.blueGrey[900],
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (directionIndex == 0 || directionIndex == 1) return;
            directionIndex = details.delta.dy > 0 ? 1 : 0;
          },
          onHorizontalDragUpdate: (details) {
            if (directionIndex == 2 || directionIndex == 3) return;
            directionIndex = details.delta.dx > 0 ? 3 : 2;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.black.withOpacity(0.5),
                child: Text(
                  'Bolas comidas: $ballsEaten',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: <Widget>[
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridSize,
                          ),
                          itemCount: gridSize * gridSize,
                          itemBuilder: (BuildContext context, int index) {
                            final int x = index % gridSize;
                            final int y = index ~/ gridSize;
                            if (snake
                                .any((pos) => pos[0] == x && pos[1] == y)) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            } else if (food[0] == x && food[1] == y) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: togglePause,
                      child: Text(isPaused ? 'Reanudar' : 'Pause'),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: restartGame,
                      child: Text('Reiniciar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
