# vhdl-log

VHDL log package implementing simple logging mechanism.
The one you have always wanted to use.
It allows logging to the stdout (default) or to a regular file.

More robust documentaiton can be found in the `log.vhd` file.
The `test.vhd` file can also serve as an example.

## Example

```vhdl
library work;
   use work.log;

entity test is
end entity;

architecture tb of test is
begin
   main : process is
   begin
      wait for 2.5 ns;
      log.failure("FAILURE");
   end process;
end architecture;
```
### Output
```
failure: 2.5 ns: FAILURE
simulation finished @2500ps with status 1
```
