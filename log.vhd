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
      level         : t_level;
      show_level    : boolean;
      time_unit     : time;
      show_sim_time : boolean;
      prefix        : string(1 to 32);
      separator     : string(1 to 3);
   end record;

   constant DEFAULT_CONFIG : t_config := (
      level         => INFO,
      show_level    => true,
      time_unit     => ns,
      show_sim_time => true,
      prefix        => (others => nul),
      separator     => ": " & nul
   );

   type t_logger is protected
      impure function config return t_config;
      procedure set_config(c : t_config);

      procedure trace(msg : string);
      procedure debug(msg : string);
      procedure info(msg : string);
      procedure warn(msg : string);
      procedure error(msg : string);
   end protected;

   shared variable logger : t_logger;

   procedure set_level(l : t_level);

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

      variable cfg : t_config := DEFAULT_CONFIG;

      impure function config return t_config is begin return cfg; end function;
      procedure set_config(c : t_config) is begin cfg := c; end procedure;

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
         if lvl < cfg.level then return; end if;

         if cfg.show_sim_time then
            write(time_line, now, left, MAX_TIME_LEN, cfg.time_unit);
            time := time_line.all;
            trim_time(time);
         end if;

         write(output, t_level'image(lvl) & cfg.separator & time & cfg.separator &  msg & LF);
      end procedure;


      procedure trace(msg : string) is begin log(TRACE, msg); end procedure;
      procedure debug(msg : string) is begin log(DEBUG, msg); end procedure;
      procedure info(msg : string) is begin log(INFO, msg); end procedure;
      procedure warn(msg : string) is begin log(WARN, msg); end procedure;
      procedure error(msg : string) is begin log(ERROR, msg); end procedure;

   end protected body;

   procedure set_level(l : t_level) is
      variable c : t_config;
   begin
      c := logger.config;
      c.level := l;
      logger.set_config(c);
   end procedure;

end package body;
