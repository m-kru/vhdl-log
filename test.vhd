library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;

library work;
   use work.log;

entity test is
end entity;

architecture tb of test is
begin
   main : process is
   begin
      wait for 7.5 ns;

      log.config.level := log.DEBUG;
      log.config.show_level := true;
      log.config.show_sim_time := true;
      log.config.time_unit := ns;

      log.config.len := 64;
      log.log(log.INFO, "Lorem");
      log.log(log.ERROR, "ipsum");

      std.env.finish;
   end process;
end architecture;
