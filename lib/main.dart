import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(PenaltyShootoutApp());
}

class PenaltyShootoutApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Penalty Shootout',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PenaltyGame(), // Llama a la clase
    );
  }
}

class PenaltyGame extends StatefulWidget {

  @override
  _PenaltyGameState createState() => _PenaltyGameState();
}

class _PenaltyGameState extends State<PenaltyGame> {
  //----VARIABLES----//
  int playerScore = 0;
  int cpuScore = 0;
  bool isPlayerTurn = true;
  List<List<int>> playerSelectedTiles = []; // En esta var se guardan los cuadrados selecionados del usr
  List<List<int>> cpuSelectedTiles = []; // En esta var se guardan los cuadrados selecionados del CPU
  List<int>? hoveredTile;  // Nueva variable para el hover
  //----VARIABLES----//

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Penalty Shootout"),
      ),
      body: Center( // el child column donde se guarda la grid hereda del body Center para que todos los elementos esten centrados
        child: Column( //hijo donde se va a almacenar la grid
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ //TODA LA GRID
          Text(
            "Elián Fc: $playerScore | CPU: $cpuScore",
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SizedBox(
              width: 350, 
              height: 250,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, //columnas
                  mainAxisSpacing: 4.0, //espaciado entre filas
                  crossAxisSpacing: 4.0, //espaciado entre columnas
                  childAspectRatio: 1.0, //Para que la grid sean cuadraditos
                ),
                itemCount: 35, //35 cuadraditos selecionables (5x7 = 35)
                itemBuilder: (context, index) {
                  int row = index ~/ 7; // Calculate row from index
                  int col = index % 7;  // Calculate column from index

                  return MouseRegion(
                    onEnter: (_) => _onHoverEnter(row, col),  // Detectar cuando el mouse entra en el cuadrado
                    onExit: (_) => _onHoverExit(),  // Detectar cuando el mouse sale del cuadrado
                    child: GestureDetector( // checkear el estado del bool playerturn para saber si el usr ataja o patea
                      onTap: () {
                        if (isPlayerTurn) {
                          handlePlayerShoot(row, col); //si es el turno del player, llama a la funcion para patear
                        } else {
                          handlePlayerSave(row, col); //si es false, por ende el player ataja
                        }
                      },
                      child: GridTile( // Estilo de cada cuadrado
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: getColorForTile(row, col),
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20)
        ],
      ),
      ),
    );
  }

  // Método para manejar la entrada del cursor en una casilla
  void _onHoverEnter(int row, int col) {
    setState(() {
      hoveredTile = [row, col];
    });
  }

  // Método para manejar la salida del cursor de una casilla
  void _onHoverExit() {
    setState(() {
      hoveredTile = null;
    });
  }

  //----LOGICA DE PATEAR PLAYER----//
  void handlePlayerShoot(int row, int col) {
    setState(() {
      playerSelectedTiles = [
        [row, col]
      ];
      // una vez guarda los valores en pselectedtiles, llama a la f para que la cpu ataje random y la que compara para ver si es gol
      cpuSelectSaveZone();
      checkGoalOrSave();
      // Esperamos un momento para que el usuario vea la jugada, luego limpiamos la matriz
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix(); // Limpiar la matriz
        setState(() {
          isPlayerTurn = false; // Cambiamos el turno al portero
        });
      });
    });
  }

  //----LOGICA DE ATAJAR PLAYER----//
  void handlePlayerSave(int row, int col) {
    setState(() {
      playerSelectedTiles = get3x3Zone(row, col);
      cpuSelectShootZone();
      checkGoalOrSave();

      // Esperamos un momento para que el usuario vea la jugada, luego limpiamos la matriz
      Future.delayed(Duration(seconds: 1), () {
        clearMatrix(); // Limpiar la matriz
        setState(() {
          isPlayerTurn = true; // Cambiamos el turno al ejecutor
        });
      });
    });
  }

  // Función para limpiar la matriz entre turnos
  void clearMatrix() {
    playerSelectedTiles.clear();
    cpuSelectedTiles.clear();
  }

  List<List<int>> get3x3Zone(int row, int col) {
    List<List<int>> selectedTiles = [];

    // Ajustar los límites para asegurar que el cuadrado 3x3 no se salga de la matriz
    int startRow = (row - 1 < 0) ? 0 : (row + 1 > 4) ? 2 : row - 1;
    int startCol = (col - 1 < 0) ? 0 : (col + 1 > 6) ? 4 : col - 1;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        selectedTiles.add([startRow + i, startCol + j]);
      }
    }

    return selectedTiles; // Retornar las casillas ajustadas
  }

  //----LOGICA CPU ATAJAR----//
  void cpuSelectSaveZone() {
    setState(() {
      cpuSelectedTiles = getRandom3x3Zone(); // Cambiamos a un área 3x3
    });
  }

  //----CPU 3X3 RANDOM----//
  List<List<int>> getRandom3x3Zone() {
    int row = Random().nextInt(5); // Limitamos a 5 para que no se salga del borde inferior
    int col = Random().nextInt(7); // Limitamos a 7 para que no se salga del borde derecho
    return get3x3Zone(row, col); // Reutilizamos la misma lógica para obtener el área 3x3
  }

  //----LOGICA DE PATEO CPU----//
  void cpuSelectShootZone() {
    setState(() {
      int row = Random().nextInt(5); // Random() para elegir coords al azar en una de las 5 filas
      int col = Random().nextInt(7); // Random() para elegir coords al azar en una de las 7 columnas
      cpuSelectedTiles = [
        [row, col]
      ];
    });
  }

  //----COMPROBACIONES PARA VER SI ES GOL----//
  void checkGoalOrSave() {
    if (isPlayerTurn) { //si es el turno del usr, se comprueba si mete gol, si sí, incrementa la var playerscore
      if (cpuSelectedTiles.any((tile) => tile[0] == playerSelectedTiles[0][0] && tile[1] == playerSelectedTiles[0][1])) {
        print("CPU atajo");
      } else {
        playerScore++;
        print("USR gol");
      }
    } else {
      //si es el turno de patear de la cpu, se comprueba si mete gol, si sí, incrementa la var playerscore
      if (playerSelectedTiles.any((tile) => tile[0] == cpuSelectedTiles[0][0] && tile[1] == cpuSelectedTiles[0][1])) {
        print("USR atajo");
      } else {
        cpuScore++;
        print("CPU gol");
      }
    }
  }

// Método para obtener el área 3x3 alrededor del cuadrado donde está el cursor
List<List<int>> getHovered3x3Zone(int row, int col) {
  List<List<int>> hoveredTiles = [];

  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      int newRow = row + i;
      int newCol = col + j;
      // Nos aseguramos de que no salimos de los límites de la matriz (7x5)
      if (newRow >= 0 && newRow < 5 && newCol >= 0 && newCol < 7) {
        hoveredTiles.add([newRow, newCol]);
      }
    }
  }

  return hoveredTiles; // Retornamos las casillas alrededor del hover
}

  // Actualización del método para determinar el color de cada casilla
Color getColorForTile(int row, int col) {
  // Priorizar el disparo de la CPU si coincide con una casilla
  if (cpuSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
    return Colors.red; // Mostrar el disparo de la CPU (rojo)
  } 
  // Mostrar el área seleccionada por el usuario
  else if (playerSelectedTiles.any((tile) => tile[0] == row && tile[1] == col)) {
    return Colors.blue; // Mostrar el área seleccionada por el usuario (celeste)
  } 
  // Mostrar el hover del usuario para el área 3x3
  else if (hoveredTile != null) {
    if (!isPlayerTurn) {
      // Si el usuario está atajando, mostrar el área 3x3
      if (isInHovered3x3Zone(row, col)) {
        return const Color.fromARGB(255, 91, 195, 107); // Color para el área 3x3
      }
    } else {
      // Si el usuario está pateando, mostrar solo la casilla debajo del cursor
      if (hoveredTile![0] == row && hoveredTile![1] == col) {
        return const Color.fromARGB(255, 91, 195, 107); // Color para el hover en una sola casilla
      }
    }
  }
  
  return Colors.white; // Casillas no seleccionadas
}



  // Función para verificar si una casilla está en el área 3x3 alrededor del cursor
  bool isInHovered3x3Zone(int row, int col) {
    if (hoveredTile == null) return false;

    List<List<int>> hoveredArea = getHovered3x3Zone(hoveredTile![0], hoveredTile![1]);

    return hoveredArea.any((tile) => tile[0] == row && tile[1] == col);
  }

}