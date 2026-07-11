using { sap.common.CodeList as CodeList } from '@sap/cds/common';

namespace gas.common;
// UNIDAD DE MEDIDA 
entity UnidadMedida : CodeList {
  key code : String enum {
    L;  // Litros
    KM; // Kilómetros
    H;  // Horas
    KG; // Kilogramos
    T;  // Toneladas
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
} 
// UNIDAD DE MEDIDA PARA RENDIMIENTO (KM/L, H/L)
entity MedicionGaso : CodeList {
  key code : String enum {
    KM_L; // Kilómetros por litro
    H_L; // Horas por litro

  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
    
}
// ESTADO DE VIAJE
entity EstadoViaje : CodeList {
  key code : String enum {
    Programado;
    EnCurso;
    Finalizado;
    Cancelado;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
    
}

entity VH_State : CodeList {
  key code : String enum {
    Operativo;
    Mantenimiento;
    FueraDeServicio
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
  criticality : Integer;
}

// NUMERO DE EJES DEL CAMION
entity EjesCamion : CodeList {
  key code : String enum {
    DosEjes;
    TresEjes;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
}

// NUMERO DE TANQUES (1 o 2)
entity NumeroTanques : CodeList {
  key code : Integer enum {
    Uno = 1;
    Dos = 2;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
}

// CONFIGURACION DEL CAMION
entity ConfiguracionCamion : CodeList {
  key code : String enum {
    TractoCamion;
    Volqueta;
    Toronto_ChasisLargo;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
}

// MODELOS DE MOTOR
entity ModeloMotor : CodeList {
  key code : String enum {
    Mack_E7_330;
    Mack_E7_350;
    Mack_E7_427;
    Mack_MP8_440;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
}

entity TipoEmisiones : CodeList {
  key code : String enum {
    NO_NORMA;
    EURO2;
    EURO3;
    EURO4;
    EURO5;
    EURO6;
    ANULADO;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
  requiereUrea : Boolean;
  requiereAceiteSintetico : Boolean;
  sensibilidadGasoil : String;
  
}
entity TanqueEstado : CodeList {
  key code : String enum {
    Activo;
    Mantenimiento;
    Inactivo;
  };
  name  : String @UI : { Hidden };
  descr : String @UI : { Hidden };
}