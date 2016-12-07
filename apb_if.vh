// File name:   apb_if.vh
// Created:     12/6/2016
// Author:      Nithin V
// Description: Interface for APB

`ifndef APB_IF_VH
`define APB_IF_VH

interface apb_if;
   logic [31:0] PADDR;
   logic [31:0] PRDATA;
   logic [31:0] PWDATA;
   logic PWRITE, PREADY, PSEL, PENABLE, PSLVERR;

   modport apb_s (
     input PADDR,PWDATA , PWRITE, PSEL, PENABLE,
     output PRDATA, PSLVERR, PREADY
   );
endinterface // apb_if

`endif //  `ifndef APB_IF_VH

