#ifndef CALIFICACION_H
#define CALIFICACION_H

#include <string>
#include <chrono>

class Calificacion {
private:
    std::string id;
    int puntaje;
    std::string comentario;
    std::chrono::system_clock::time_point fecha;

public:
    Calificacion(std::string _id, int _puntaje, std::string _comentario, std::chrono::system_clock::time_point _fecha)
        : id(_id), puntaje(_puntaje), comentario(_comentario), fecha(_fecha) {}
};

#endif