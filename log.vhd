-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2022 Michał Kruszewski

library std;
   use std.textio.all;

-- Log package implements simple logging mechanism.
-- The one you have always wanted to use.
package log is

   type t_level is (TRACE, DEBUG, INFO, WARN, ERROR);

   type t_logger is protected
      -- Level returns current logger logging level.
      impure function level return t_level;
      -- Set_level sets logger logging level.
      procedure set_level(lvl : t_level);

      -- Enable_level enables printing logger level.
      procedure enable_level;
      -- Disable_level disables printing logger level.
      procedure disable_level;

      -- Time_unit returns current logger time unit used for simulator time printing.
      impure function time_unit return time;
      -- Set_time_unit sets logger time unit used for simulator time printing.
      procedure set_time_unit(tu : time);

      procedure trace(msg : string);
      procedure debug(msg : string);
      procedure info(msg : string);
      procedure warn(msg : string);
      procedure error(msg : string);
   end protected;

   shared variable logger : t_logger;

   procedure trace(msg : string);
   procedure debug(msg : string);
   procedure info(msg : string);
   procedure warn(msg : string);
   procedure error(msg : string);

end package;

package body log is

   procedure trace(msg : string) is begin logger.trace(msg); end procedure;
   procedure debug(msg : string) is begin logger.debug(msg); end procedure;
   procedure info(msg : string) is begin logger.info(msg); end procedure;
   procedure warn(msg : string) is begin logger.warn(msg); end procedure;
   procedure error(msg : string) is begin logger.error(msg); end procedure;

   type t_logger is protected body

      type t_config is record
         level         : t_level;
         show_level    : boolean;
         time_unit     : time;
         show_sim_time : boolean;
      end record;

      constant DEFAULT_CONFIG : t_config := (
         level         => INFO,
         show_level    => true,
         time_unit     => ns,
         show_sim_time => true
      );

      variable config : t_config := DEFAULT_CONFIG;


      impure function level return t_level is begin return config.level; end function;
      procedure set_level(lvl : t_level) is begin config.level := lvl; end procedure;

      procedure enable_level is begin config.show_level := true; end procedure;
      procedure disable_level is begin config.show_level := false; end procedure;


      impure function time_unit return time is begin return config.time_unit; end function;
      procedure set_time_unit(tu : time) is begin config.time_unit := tu; end procedure;


      procedure log(lvl : t_level; msg : string) is
         constant MAX_TIME_LEN : positive := 32;
         variable time : string(1 to MAX_TIME_LEN);
         variable time_line : line;

         procedure trim_time(t : inout string) is
         begin
            for i in t'reverse_range loop
               if t(i) = ' ' then time(i) := nul; else return; end if;
            end loop;
         end procedure;
      begin
         if lvl < config.level then return; end if;

         if config.show_sim_time then
            write(time_line, now, left, MAX_TIME_LEN, config.time_unit);
            time := time_line.all;
            trim_time(time);
         end if;

         write(output, t_level'image(lvl) & ": " & time & ": " &  msg & LF);
      end procedure;


      procedure trace(msg : string) is begin log(TRACE, msg); end procedure;
      procedure debug(msg : string) is begin log(DEBUG, msg); end procedure;
      procedure info(msg : string) is begin log(INFO, msg); end procedure;
      procedure warn(msg : string) is begin log(WARN, msg); end procedure;
      procedure error(msg : string) is begin log(ERROR, msg); end procedure;

   end protected body;

end package body;
