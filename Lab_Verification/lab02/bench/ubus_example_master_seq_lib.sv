
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
      
    // READ A RANDOM LOCATION
    `uvm_do_with(read_seq0, {read_seq0.transmit_del == 0; })
    addr_check = read_seq0.rsp.addr;
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

//...SEQUENCE DE TEST POUR CONFIGURER LE FILTRE...................................................

class init_seq_and_go extends ubus_base_sequence;

  function new(string name="init_seq_and_go");
    super.new(name);
  endfunction : new

  `uvm_object_utils(init_seq_and_go)

  write_seq write_seq0;
  
  rand int N_filtre=4; // Nombre de coeffs a initialiser
  rand bit A_filtre=1; // Valeur d'activation

  virtual task body();
     
     int ii;
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
    
    for(ii = 1; ii < N_filtre+1; ii++)
    begin
      `uvm_do_with(write_seq0, { write_seq0.start_addr == ii; }) // Ecrire sur les registres de coeffs du filtre
    end
    
    `uvm_do_with(write_seq0, { write_seq0.start_addr == 0;
                               write_seq0.data0 == A_filtre; }) // Ecrire sur le registre de configuration la valeur 1 pour commencer le filtrage

  endtask : body

endclass : init_seq_and_go


//...SEQUENCE DE TEST POUR ECRIRE PLUSIEURS FOIS DANS LE REGISTRE DU FILTRE.......................


class filter_random_seq extends ubus_base_sequence;

  function new(string name="filter_random_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(filter_random_seq)

  rand int count;
  constraint c_count {count>=10 && count<=20;}; // Contraint : ecrire seulement entre 10 et 20 fois!

  write_seq write_seq0;
  init_seq_and_go init_seq0;

  int N;
  
  rand int N_f=4;
  rand int A_f=1;

  virtual task body();
  //............................................................................
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
      //...APPEL  DE LA SEQUENCE INIT GO SEQ
     `uvm_do_with(init_seq0, { init_seq0.N_filtre == N_f; init_seq0.A_filtre == A_f; });
      
     for(N=0; N<count; N++)
       `uvm_do_with(write_seq0, { write_seq0.start_addr == 'h21; }); // Lancer la sequence d'ecriture avec le contraint c_count
      
  endtask : body

endclass : filter_random_seq

//...SEQUENCE DE TEST POUR RANDOMISER L'INITIALISATION DU FILTRE ET AUSSI LE NOMBRE D'ECRITURE........................

class random_activate_deactivate_seq extends ubus_base_sequence;

  function new(string name="random_activate_deactivate_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(random_activate_deactivate_seq)

  write_seq write_seq0;
  filter_random_seq filter_random_seq0;

  rand int K;
  constraint K_count { K >= 1 && K <= 10; };
  
  rand int Active_coeff;
  constraint Active_coeff_count { Active_coeff >= 1 && Active_coeff <= 4; };
  
  rand bit Active_filtre;
//  constraint Active_filtre_val { Active_filtre [15:1] >= 0 && Active_filtre [15:1] <= 1; };
//  constraint Active_filtre_val { Active_filtre inside { [0:1]; } };

  int ii;

  virtual task body();
      
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
      
    for(ii=0; ii<K; ii++)
      `uvm_do_with(filter_random_seq0, { filter_random_seq0.N_f == Active_coeff; filter_random_seq0.A_f == Active_filtre; });
      
  endtask : body

endclass : random_activate_deactivate_seq

//...SEQUENCE DE TEST POUR FORCER LE TRANSFER DELAY A 0..................................................... 

class transfer_delay_0_seq extends ubus_base_sequence;

  function new(string name="transfer_delay_0_seq");
    super.new(name);
  endfunction : new

  `uvm_object_utils(transfer_delay_0_seq)

  rand int count;
  constraint c_count {count>=10 && count<=20;}; // Contraint : ecrire seulement entre 10 et 20 fois!

  write_seq write_seq0;
  init_seq_and_go init_seq0;

  int N;

  virtual task body();
  //............................................................................
    `uvm_info(get_type_name(),
      $sformatf("%s starting...",
      get_sequence_path()), UVM_MEDIUM);
      //...APPEL  DE LA SEQUENCE INIT GO SEQ
     `uvm_do_with(init_seq0, { init_seq0.N_filtre == 4; init_seq0.A_filtre == 1; });
      
     for(N=0; N<count; N++)
       `uvm_do_with(write_seq0, { write_seq0.start_addr == 'h21; write_seq0.transmit_del == 7; }); // Lancer la sequence d'ecriture avec le contraint c_count
      
  endtask : body

endclass : transfer_delay_0_seq