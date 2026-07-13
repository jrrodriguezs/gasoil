using { cuid, managed } from '@sap/cds/common';

namespace gas.app;

entity Rubros: cuid, managed {
    name: String(50);
    description: String(255);
}
