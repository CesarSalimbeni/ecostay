#ifndef RESERVA_H
#define RESERVA_H

#include <string>
#include <chrono>
#include "EstadoReserva.h"

class Reserva {
private:
    std::string id;
    std::chrono::system_clock::time_point fechaInicio;
    std::chrono::system_clock::time_point fechaFin;
    EstadoReserva estado;
    double total;

public:
    Reserva(std::string _id, std::chrono::system_clock::time_point _fechaInicio, 
            std::chrono::system_clock::time_point _fechaFin, EstadoReserva _estado, double _total)
        : id(_id), fechaInicio(_fechaInicio), fechaFin(_fechaFin), estado(_estado), total(_total) {}

    // Métodos del diagrama
    void confirmar() {
        // TODO: Implementar lógica de confirmación
    }

    void cancelar() {
        // TODO: Implementar lógica de cancelación
    }
};

#endif