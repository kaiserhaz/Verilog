//----------------------------------------------------------------------
//   Copyright 2007-2010 Mentor Graphics Corporation
//   Copyright 2007-2010 Cadence Design Systems, Inc.
//   Copyright 2010 Synopsys, Inc.
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

//------------------------------------------------------------------------------
//
// CLASS: ubus_example_scoreboard
//
//------------------------------------------------------------------------------
// Declare the suffixes that will be appended to the imps and functions
`uvm_analysis_imp_decl(_MASTER)
`uvm_analysis_imp_decl(_SLAVE)

class ubus_example_scoreboard extends uvm_scoreboard;

  uvm_analysis_imp_MASTER #(ubus_transfer, ubus_example_scoreboard) master_export;
  uvm_analysis_imp_SLAVE #(slave_transfer, ubus_example_scoreboard) slave_export;

  protected bit disable_scoreboard = 0;
  protected bit filter_enable = 0;
  protected bit unsigned [3:0] filter_size = 0;
  protected bit unsigned [15:0] coef[4] = '{4{0}};
  protected bit unsigned [15:0] register[4] = '{4{0}};
  protected bit unsigned [31:0] intermed[4] = '{4{0}};
  protected bit unsigned [31:0] filter_temp = 0;
  protected bit unsigned [15:0] filter_data = 0;
  protected bit unsigned [2:0] filter_tap = 0;
  protected bit filter_valid = 0;
  protected bit filter_overflow = 0;
  protected bit filter_error = 0;
  protected bit unsigned [15:0] compare_in = 0;
  int sbd_error = 0;

  protected int unsigned m_mem_expected[int unsigned];

  // Provide implementations of virtual methods such as get_type_name and create
  `uvm_component_utils_begin(ubus_example_scoreboard)
    `uvm_field_int(disable_scoreboard, UVM_DEFAULT)
    `uvm_field_int(filter_enable, UVM_DEFAULT)
    `uvm_field_int(filter_size, UVM_DEFAULT)
    `uvm_field_sarray_int(coef, UVM_DEFAULT)
    `uvm_field_sarray_int(register, UVM_DEFAULT)
    `uvm_field_sarray_int(intermed, UVM_DEFAULT)
    `uvm_field_int(filter_temp, UVM_DEFAULT)
    `uvm_field_int(filter_data, UVM_DEFAULT)
    `uvm_field_int(filter_tap, UVM_DEFAULT)
    `uvm_field_int(filter_valid, UVM_DEFAULT)
    `uvm_field_int(filter_overflow, UVM_DEFAULT)
    `uvm_field_int(filter_error, UVM_DEFAULT)
    `uvm_field_int(compare_in, UVM_DEFAULT)
  `uvm_component_utils_end

  // new - constructor
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  //build_phase
  function void build_phase(uvm_phase phase);
    master_export = new("master_export", this);
    slave_export = new("slave_export", this);
  endfunction

  // write
  virtual function void write_MASTER(ubus_transfer trans);
    if(!disable_scoreboard)
      compute_data(trans);
  endfunction : write_MASTER

  // write
  virtual function void write_SLAVE(slave_transfer trans);
    if(!disable_scoreboard)
      compare_data(trans);
  endfunction : write_SLAVE

  // compute_data
  protected function void compute_data(input ubus_transfer trans);
    filter_error = 0;
    case(trans.read_write)
      WRITE: begin
        case(trans.addr)
          6'h0: begin
            this.filter_enable = trans.data[0];
            if(trans.data[1]) begin
              this.register[0] = 0;
              this.register[1] = 0;
              this.register[2] = 0;
              this.register[3] = 0;
              this.filter_tap = 0;
            end
            this.filter_size = trans.data[7:4];
          end
          6'h1: this.coef[3] = trans.data; //had to invert with coef[0]
          6'h2: this.coef[2] = trans.data; //had to invert with coef[1]
          6'h3: this.coef[1] = trans.data; //had to invert with coef[2]
          6'h4: this.coef[0] = trans.data; //had to invert with coef[3]
          6'h21: if(this.filter_enable) begin
            this.register[3] = this.register[2];
            this.register[2] = this.register[1];
            this.register[1] = this.register[0];
            this.register[0] = trans.data;
            //
            if(this.filter_tap<4)
              this.filter_tap++;
            //
            for(int ii=0; ii<4; ii++)
              this.intermed[ii] = coef[ii]*register[ii];
            //
            case(this.filter_size)
              0: this.filter_temp = intermed[0];
              1: this.filter_temp = intermed[0] + intermed[1];
              2: this.filter_temp = intermed[0] + intermed[1] + intermed[2];
              default: this.filter_temp = intermed[0] + intermed[1] + intermed[2] + intermed[3];
            endcase
            filter_data = filter_temp;
            //
            if(this.filter_tap>= this.filter_size+1)
              this.filter_valid = 1;
            else
              this.filter_valid = 0;
            //
            if(&this.filter_temp[31:16])
              this.filter_overflow = 1;
            else
              this.filter_overflow = 0;
              filter_error = 0;
          end else
              filter_error = 1;
          default: filter_error = 1;
        endcase
      end
      READ: begin
        case(trans.addr)
          6'h0: assert(trans.data[7:4] == this.filter_size
                        && trans.data[0] == this.filter_enable)
                else report_scoreboard_fatal();
          6'h01:  assert(trans.data == this.coef[3])
                  else report_scoreboard_fatal();
          6'h02:  assert(trans.data == this.coef[2])
                  else report_scoreboard_fatal();
          6'h03:  assert(trans.data == this.coef[1])
                  else report_scoreboard_fatal();
          6'h04:  assert(trans.data == this.coef[0])
                  else report_scoreboard_fatal();
          6'h11:  assert(trans.data == this.register[3])
                  else report_scoreboard_fatal();
          6'h12:  assert(trans.data == this.register[2])
                  else report_scoreboard_fatal();
          6'h13:  assert(trans.data == this.register[1])
                  else report_scoreboard_fatal();
          6'h14:  assert(trans.data == this.register[0])
                  else report_scoreboard_fatal();
          6'h20:  assert(trans.data[0] == this.filter_overflow)
                  else report_scoreboard_fatal();
          default: filter_error = 1;
        endcase
      end
    endcase
    report_scoreboard_info();
  endfunction : compute_data

  // compare_data
  protected function void compare_data(input slave_transfer trans);
    if(trans.action == DATA && filter_enable)
      assert(trans.data == this.filter_data
              && trans.valid == this.filter_valid
              && trans.overflow == this.filter_overflow)
      else
        report_scoreboard_fatal();
    else if((trans.action == DATA && !filter_enable) || trans.action == ERROR)
      assert(trans.error == this.filter_error && this.filter_error)
      else
        report_scoreboard_fatal();
  endfunction : compare_data

  // report_phase
  virtual function void report_phase(uvm_phase phase);
    if(!disable_scoreboard)
      report_scoreboard_info();
  endfunction : report_phase

  // report_phase
  virtual function void report_scoreboard_info();
    `uvm_info(get_type_name(),
      $sformatf("Reporting scoreboard information...\n%s", this.sprint()), UVM_LOW)
  endfunction : report_scoreboard_info

  // report_phase
  virtual function void report_scoreboard_fatal();
    `uvm_fatal(get_type_name(),
      $sformatf("Reporting scoreboard FAILURE...\n%s", this.sprint()))
  endfunction : report_scoreboard_fatal

endclass : ubus_example_scoreboard


