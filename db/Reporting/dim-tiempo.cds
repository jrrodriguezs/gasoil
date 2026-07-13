namespace gas.reporting;

entity DimTiempo {
  key dateKey           : String(8);   // YYYYMMDD
      fecha              : Date;
      anio               : Integer;
      mes                : Integer;
      dia                : Integer;
      trimestre          : Integer;    // 1, 2, 3, 4
      semanaAnio         : Integer;    // ISO week 1-53
      diaSemana          : Integer;    // 1=Lunes, 7=Domingo
      nombreMes          : String(10);
      nombreDia          : String(10);
      esFinDeSemana      : Boolean default false;
      esFeriado          : Boolean default false;
      periodoYMD         : String(6);  // YYYYMM
      periodoYQT         : String(7);  // YYYY-Q1
      diasDesdeInicioAnio : Integer;
      diasHastaFinAnio    : Integer;
}
