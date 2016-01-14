
class read_modify_write_seq extends ubus_base_sequence;

  function new(string name="read_modify_write_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(read_modify_write_seq)

  read_seq  read_seq0;
  write_seq write_seq0;

  rand bit [5:0] addr_check;
  bit [15:0] m_data0_check;

  virtual task body();
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    addr_check = 'h1;
    
    // READ A RANDOM LOCATION
    `uvm_do_with(read_seq0, { read_seq0.start_addr == addr_check;
                              read_seq0.transmit_del == 0; })
    //addr_check = read_seq0.rsp.addr;
    m_data0_check = read_seq0.rsp.data + 1;
      
    // WRITE MODIFIED READ DATA
    `uvm_do_with(write_seq0,
      { write_seq0.start_addr == addr_check;
        write_seq0.data0 == m_data0_check; } )
      
    // READ MODIFIED WRITE DATA
    `uvm_do_with(read_seq0,
      { read_seq0.start_addr == addr_check; } )
      
    assert(m_data0_check == read_seq0.rsp.data) else
      `uvm_error(get_type_name(),
        $sformatf("%s Read Modify Write Read error!\n\tADDR: %h, EXP: %h, ACT: %h", 
        get_sequence_path(),addr_check,m_data0_check,read_seq0.rsp.data));
  endtask : body

endclass : read_modify_write_seq


class init_and_go_seq extends ubus_base_sequence;

  function new(string name="init_and_go_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(init_and_go_seq)

  read_seq  read_seq0;
  write_seq write_seq0;

  rand bit [5:0] addr_check;
  rand bit transmit_delay_null[5];
  rand bit unsigned [3:0] filter_size;
  constraint filter_size_c { filter_size >=0 && filter_size <=3; }

  virtual task body();
    
    
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    for(addr_check=1; addr_check<=4;addr_check++) begin
      
      // WRITE COEF
      `uvm_do_with(write_seq0,
        { write_seq0.start_addr == addr_check;
          write_seq0.transmit_del == 0 || transmit_delay_null[addr_check-1] == 0; } )
    
    end
    
    for(addr_check=1; addr_check<=4;addr_check++) begin
      
      // READ COEF
      `uvm_do_with(read_seq0,
        { read_seq0.start_addr == addr_check;
          read_seq0.transmit_del == 0 || transmit_delay_null[addr_check-1] == 0; } )
    
    end
    
    
    // WRITE CONFIG
    `uvm_do_with(write_seq0,
      { write_seq0.start_addr == 0;
        write_seq0.data0 == {filter_size, 4'h1};
        write_seq0.transmit_del == 0 || transmit_delay_null[4] == 0; } )
    
    
    // READ CONFIG
    `uvm_do_with(read_seq0,
      { read_seq0.start_addr == 0;
        read_seq0.transmit_del == 0 || transmit_delay_null[4] == 0; } )
      
  endtask : body

endclass : init_and_go_seq


class filter_random_seq extends ubus_base_sequence;

  function new(string name="filter_random_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(filter_random_seq)

  read_seq  read_seq0;
  write_seq write_seq0;
  init_and_go_seq init_and_go_seq0;

  rand int count;
  constraint c_count { count >= 10 && count <= 20; };
  
  rand bit unsigned [3:0] filter_size2;
  constraint filter_size2_c { filter_size2 >=3 && filter_size2 <=3; }

  virtual task body();
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    // INIT AND GO
    `uvm_do_with(init_and_go_seq0, { init_and_go_seq0.filter_size == filter_size2;  })
    
        
    for(int ii=1; ii<=count;ii++) begin
      
      // WRITE DATA
      `uvm_do_with(write_seq0, { write_seq0.start_addr == 'h21; } )
      
      for(int jj=0; jj<=filter_size2; jj++) begin
        // READ VALUES
        `uvm_do_with(read_seq0, { read_seq0.start_addr == 'h11 + jj; } )
      end
      
      // READ STATUS
      `uvm_do_with(read_seq0, { read_seq0.start_addr == 'h20; } )
      
      // READ ERROR
      `uvm_do_with(read_seq0, { read_seq0.start_addr == 'h21; } )
      
      // WRITE ERROR
      `uvm_do_with(write_seq0, { write_seq0.start_addr inside { ['h11:'h14], 'h20}; } )
      
    end
  endtask : body

endclass : filter_random_seq


class random_init_and_go_seq extends init_and_go_seq;

  function new(string name="random_init_and_go_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(random_init_and_go_seq)

  rand bit init_coef[4];
  rand bit init_filter;

  virtual task body();
      
    `uvm_info(get_type_name(),
              $sformatf("%s starting...",
                        get_sequence_path()),
              UVM_MEDIUM);
    
    for(addr_check=1; addr_check<=4;addr_check++) begin
      if(init_coef[addr_check-1])
        // WRITE COEFFICIENTS
        `uvm_do_with(write_seq0,
                    { write_seq0.start_addr == addr_check;
                      write_seq0.transmit_del == 0 || transmit_delay_null[addr_check-1] == 0; } )
    end
    
    for(addr_check=1; addr_check<=4;addr_check++) begin
      if(init_coef[addr_check-1])
        // READ COEFFICIENTS
        `uvm_do_with(read_seq0,
          { read_seq0.start_addr == addr_check;
            read_seq0.transmit_del == 0 || transmit_delay_null[addr_check-1] == 0; } )
    
    end
    
    if(init_filter) begin
      // WRITE CONFIG
      `uvm_do_with(write_seq0, {  write_seq0.start_addr == 0;
                                  write_seq0.data0 == 1;
                                  write_seq0.transmit_del == 0 || transmit_delay_null[4] == 0; } )
      
      // READ CONFIG
      `uvm_do_with(read_seq0, {  read_seq0.start_addr == 0;
                                  read_seq0.transmit_del == 0 || transmit_delay_null[4] == 0; } )
    end
    
  endtask : body

endclass : random_init_and_go_seq


class filter_Krandom_seq extends ubus_base_sequence;

  function new(string name="filter_Krandom_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(filter_Krandom_seq)

  read_seq  read_seq0;
  write_seq write_seq0;
  random_init_and_go_seq random_init_and_go_seq0;

  rand int count;
  rand int Kcount;
  
  constraint c_count { count >= 10 && count <= 20; };
  constraint c_Kcount { Kcount >= 1 && Kcount <= 10; };

  virtual task body();
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    for(int ii=1; ii<=Kcount;ii++) begin
      // INIT AND GO
      `uvm_do_with(random_init_and_go_seq0, {   })
        
      for(int ii=1; ii<=count;ii++) begin
        // WRITE DATA
        `uvm_do_with(write_seq0, { write_seq0.start_addr == 'h21; } )
      end
    end
  endtask : body

endclass : filter_Krandom_seq


class filter_Krandom_nodelay_seq extends ubus_base_sequence;

  function new(string name="filter_Krandom_nodelay_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(filter_Krandom_nodelay_seq)

  read_seq  read_seq0;
  write_seq write_seq0;
  random_init_and_go_seq random_init_and_go_seq0;

  rand int count;
  rand int Kcount;
  
  constraint c_count { count >= 10 && count <= 20; };
  constraint c_Kcount { Kcount >= 1 && Kcount <= 10; };

  virtual task body();
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    for(int ii=1; ii<=Kcount;ii++) begin
      // INIT AND GO
      `uvm_do_with(random_init_and_go_seq0,
                    { random_init_and_go_seq0.transmit_delay_null[0] == 1;
                      random_init_and_go_seq0.transmit_delay_null[1] == 1;
                      random_init_and_go_seq0.transmit_delay_null[2] == 1;
                      random_init_and_go_seq0.transmit_delay_null[3] == 1;
                      random_init_and_go_seq0.transmit_delay_null[4] == 1;  })
        
      for(int ii=1; ii<=count;ii++) begin
        // WRITE DATA
        `uvm_do_with(write_seq0, { write_seq0.start_addr == 'h21;
                                   write_seq0.transmit_del == 0; } )
      end
    end
  endtask : body

endclass : filter_Krandom_nodelay_seq

