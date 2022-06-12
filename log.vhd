-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2022 Michał Kruszewski

library std;
   use std.textio.all;

-- Log package implements simple logging mechanism.
-- The one you have always wanted to use.
package log is

   type t_level is (TRACE, DEBUG, INFO, WARN, ERROR);

   type t_config is record
      len           : natural;

      show_level    : boolean;
      level         : t_level;

      show_sim_time : boolean;
      time_unit     : time;
   end record;

   shared variable config : t_config;

   procedure log(level : t_level; msg : string);

end package;

package body log is

   procedure log(level : t_level; msg : string) is
      constant MAX_TIME_LEN : positive := 32;
      variable time : string(0 to MAX_TIME_LEN-1);
      variable time_line : line;

      procedure trim_time(t : inout string) is
      begin
         for i in t'reverse_range loop
            if t(i) = ' ' then time(i) := nul; else return; end if;
         end loop;
      end procedure;
   begin
      if level < config.level then
         return;
      end if;

      if config.show_sim_time then
         write(time_line, now, left, MAX_TIME_LEN, config.time_unit);
         time := time_line.all;
         trim_time(time);
      end if;

      write(output, t_level'image(level) & ": " & time & ": " &  msg & LF);
   end procedure;

end package body;
