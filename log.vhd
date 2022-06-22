-- SPDX-License-Identifier: MIT
--
-- Copyright (c) 2022 Michał Kruszewski

library std;
   use std.textio;

-- Package log implements simple logging mechanism.
-- The one you have always wanted to use.
package log is

   type t_level is (TRACE, DEBUG, NOTE, WARNING, ERROR, FAILURE);

   -- t_config is the configuraiton type for the t_logger.
   type t_config is record
      level         : t_level;
      show_level    : boolean;
      time_unit     : time;
      show_sim_time : boolean;
      prefix        : string(1 to 32);
      separator     : string(1 to 3);
   end record;

   -- config serves as the initialization function for the t_config instance.
   -- Default values for the parameters are also used for the log package default logger.
   function config(
      level         : t_level := NOTE;
      show_level    : boolean := true;
      time_unit     : time := ns;
      show_sim_time : boolean := true;
      prefix        : string(1 to 32) := (others => nul);
      separator     : string(1 to 3) := ": " & nul
   ) return t_config;

   -- set_config sets the config of the default log package logger.
   procedure set_config(cfg : t_config);

   -- t_logger represents an active logging object that logs messages to the set output.
   -- A logger can be simultaneously used from multiple places.
   type t_logger is protected
      -- set_config sets the configuration of the logger.
      procedure set_config(c : t_config);
      -- set_output sets the output of the logger.
      -- The default output is stdout (textio.output precisely).
      procedure set_output(filepath : string);

      -- print prints the message without adding any extra information such
      -- as level or simulation time. The print prints the message regardless
      -- of the set log level. It is usally used to print extra empty lines.
      procedure print(msg : string);

      -- trace logs a message with level TRACE.
      procedure trace(msg : string);
      -- debug logs a message with level DEBUG.
      procedure debug(msg : string);
      -- note logs a message with level NOTE.
      procedure note(msg : string);
      -- warning logs a message with level WARNING.
      procedure warning(msg : string);
      -- error logs a message with level ERROR.
      procedure error(msg : string);
      -- failure logs a message with level FAILURE.
      procedure failure(msg : string);
   end protected;

   -- logger is the default log package logger used by the print, trace,
   -- debug, note, warning, error and failure log package procedures.
   shared variable logger : t_logger;

   -- print prints message using the log package logger.
   -- Check t_logger.print for more details.
   procedure print(msg : string);
   -- trace logs a message with level TRACE using the log package logger.
   procedure trace(msg : string);
   -- debug logs a message with level DEBUG using the log package logger.
   procedure debug(msg : string);
   -- note logs a message with level NOTE using the log package logger.
   procedure note(msg : string);
   -- warning logs a message with level WARNING using the log package logger.
   procedure warning(msg : string);
   -- error logs a message with level ERROR using the log package logger.
   procedure error(msg : string);
   -- failure logs a message with level FAILURE using the log package logger.
   -- Check t_logger.failure for more details.
   procedure failure(msg : string);

end package;

package body log is

   procedure print(msg : string) is begin logger.print(msg); end procedure;

   procedure trace(msg : string) is begin logger.trace(msg); end procedure;
   procedure debug(msg : string) is begin logger.debug(msg); end procedure;
   procedure note(msg : string) is begin logger.note(msg); end procedure;
   procedure warning(msg : string) is begin logger.warning(msg); end procedure;
   procedure error(msg : string) is begin logger.error(msg); end procedure;
   procedure failure(msg : string) is begin logger.failure(msg); end procedure;

   -- s0 returns string without trailing nul (0x00) bytes.
   function s0(s : string) return string is
   begin
      for i in s'range loop
         if s(i) = nul then
            return s(1 to i - 1);
         end if;
      end loop;
      return s;
   end function;

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

         -- fmt formats the output string.
         impure function fmt return string is
         begin
            return s0(cfg.prefix) & s0(time) & s0(cfg.separator) & t_level'image(lvl) & s0(cfg.separator) & s0(msg) & LF;
         end function;
      begin
         if lvl < cfg.level then return; end if;

         if cfg.show_sim_time then
            textio.write(time_line, now, textio.left, MAX_TIME_LEN, cfg.time_unit);
            time := time_line.all;
            trim_time(time);
         end if;

         if output_set then textio.write(output, fmt); else textio.write(textio.output, fmt); end if;
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
