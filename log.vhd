-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2022 Michał Kruszewski

library std;
   use std.textio;

-- Log package implements simple logging mechanism.
-- The one you have always wanted to use.
package log is

   type t_level is (TRACE, DEBUG, NOTE, WARNING, ERROR, FAILURE);

   type t_config is record
      level         : t_level;
      show_level    : boolean;
      time_unit     : time;
      show_sim_time : boolean;
      prefix        : string(1 to 32);
      separator     : string(1 to 3);
   end record;

   type t_logger is protected
      procedure set_config(c : t_config);
      procedure set_output(filepath : string);

      procedure print(msg : string);

      procedure trace(msg : string);
      procedure debug(msg : string);
      procedure note(msg : string);
      procedure warning(msg : string);
      procedure error(msg : string);
      procedure failure(msg : string);
   end protected;

   shared variable logger : t_logger;

   procedure set_config(cfg : t_config);

   procedure print(msg : string);

   procedure trace(msg : string);
   procedure debug(msg : string);
   procedure note(msg : string);
   procedure warning(msg : string);
   procedure error(msg : string);
   procedure failure(msg : string);

   function config(
      level         : t_level := NOTE;
      show_level    : boolean := true;
      time_unit     : time := ns;
      show_sim_time : boolean := true;
      prefix        : string(1 to 32) := (others => nul);
      separator     : string(1 to 3) := ": " & nul
   ) return t_config;

end package;

package body log is

   procedure print(msg : string) is begin logger.print(msg); end procedure;

   procedure trace(msg : string) is begin logger.trace(msg); end procedure;
   procedure debug(msg : string) is begin logger.debug(msg); end procedure;
   procedure note(msg : string) is begin logger.note(msg); end procedure;
   procedure warning(msg : string) is begin logger.warning(msg); end procedure;
   procedure error(msg : string) is begin logger.error(msg); end procedure;
   procedure failure(msg : string) is begin logger.failure(msg); end procedure;

   type t_logger is protected body

      variable cfg : t_config := config;

      procedure set_config(c : t_config) is begin cfg := c; end procedure;

      file output : textio.text;
      variable output_set : boolean := false;

      procedure set_output(filepath : string) is
      begin
         textio.file_open(output, filepath, write_mode);
         output_set := true;
      end procedure;

      procedure print(msg : string) is
      begin
         if output_set then textio.write(output, msg & LF); else textio.write(textio.output, msg & LF); end if;
      end procedure;

      procedure log(lvl : t_level; msg : string) is
         constant MAX_TIME_LEN : positive := 32;
         variable time : string(1 to MAX_TIME_LEN);
         variable time_line : textio.line;

         procedure trim_time(t : inout string) is
         begin
            for i in t'reverse_range loop
               if t(i) = ' ' then time(i) := nul; else return; end if;
            end loop;
         end procedure;
      begin
         if lvl < cfg.level then return; end if;

         if cfg.show_sim_time then
            textio.write(time_line, now, textio.left, MAX_TIME_LEN, cfg.time_unit);
            time := time_line.all;
            trim_time(time);
         end if;

         if output_set then
            textio.write(
               output, cfg.prefix & t_level'image(lvl) & cfg.separator & time & cfg.separator & msg & LF
            );
         else
            textio.write(
               textio.output, cfg.prefix & t_level'image(lvl) & cfg.separator & time & cfg.separator & msg & LF
            );
         end if;

      end procedure;

      procedure trace(msg : string) is begin log(TRACE, msg); end procedure;
      procedure debug(msg : string) is begin log(DEBUG, msg); end procedure;
      procedure note(msg : string) is begin log(NOTE, msg); end procedure;
      procedure warning(msg : string) is begin log(WARNING, msg); end procedure;
      procedure error(msg : string) is begin log(ERROR, msg); end procedure;
      procedure failure(msg : string) is begin log(FAILURE, msg); std.env.finish(1); end procedure;

   end protected body;

   procedure set_config(cfg : t_config) is begin logger.set_config(cfg); end procedure;

   function config(
      level         : t_level := NOTE;
      show_level    : boolean := true;
      time_unit     : time := ns;
      show_sim_time : boolean := true;
      prefix        : string(1 to 32) := (others => nul);
      separator     : string(1 to 3) := ": " & nul
   ) return t_config is
      variable cfg : t_config;
   begin
      cfg.level := level;
      cfg.show_level := show_level;
      cfg.time_unit := time_unit;
      cfg.show_sim_time := show_sim_time;
      cfg.prefix := prefix;
      cfg.separator := separator;
      return cfg;
   end function;

end package body;
