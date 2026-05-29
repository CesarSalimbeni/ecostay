#ifndef PUBLICACION_H
#define PUBLICACION_H

#include <string>
#include "Calificacion.h"

class Publicacion {
private:
    std::string id;
    std::string titulo;
    std::string descripcion;
    double precio;
    std::string ubicacion;
    bool disponibilidad;
    Calificacion calificacion; // Relación 1 a 1 según tu diagrama
    std::string politicaCancelacion;

public:
    Publicacion(std::string _id, std::string _titulo, std::string _descripcion, double _precio, 
                std::string _ubicacion, bool _disponibilidad, const Calificacion& _calificacion, 
                std::string _politicaCancelacion)
        : id(_id), titulo(_titulo), descripcion(_descripcion), precio(_precio), 
          ubicacion(_ubicacion), disponibilidad(_disponibilidad), calificacion(_calificacion), 
          politicaCancelacion(_politicaCancelacion) {}

    // Métodos del diagrama
    void editarPublicacion() {
        // TODO: Implementar lógica de edición
    }

    void eliminarPublicacion() {
        // TODO: Implementar lógica de eliminación
    }
};

#endif