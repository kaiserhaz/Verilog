/**********
 * RS232 Bus Interface
 **********
 */

/** Directives **/

/** Includes **/

/** Constants **/

/** Interface Definition **/
interface rs232_if;
  
  // Interface signals
  logic _clk;                                  // Clock
  logic _rst;                                  // Reset
  logic _eoe;                                  // End of erase
  logic _rx;                                   // Rx
  logic _tx;                                   // Tx

  // Assertions
  // Not specified at the moment

endinterface : rs232_if
