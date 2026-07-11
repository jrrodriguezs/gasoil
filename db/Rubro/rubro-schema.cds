using { cuid, managed } from '@sap/cds/common';

entity Rubros: cuid, managed {
    name: String(50);
    description: String(255);
}
