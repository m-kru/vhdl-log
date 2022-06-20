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
      variable l : log.t_logger;
   begin
      wait for 7.5 ns;

      log.set_config(log.config(log.TRACE));

      log.trace("TRACE");
      log.debug("DEBUG");
      log.info("INFO");
      log.warn("WARN");
      log.error("ERROR" & LF);

      l.set_config(
         log.config(
            level => log.TRACE,
            prefix => ("prefix: ", others => nul)
         )
      );
      l.set_output("/tmp/vhdl/vhdl-log");
      l.trace("TRACE");
      l.debug("DEBUG");
      l.info("INFO");
      l.warn("WARN");
      l.error("ERROR");

      std.env.finish;
   end process;
end architecture;
