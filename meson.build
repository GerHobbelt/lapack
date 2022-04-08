################################################################################
# Lapacke library
################################################################################
project('Lapacke library', 'c', version : '3.10.0')
################################################################################
# System info
os = host_machine.system()
cpu = host_machine.cpu_family()
ccompiler = meson.get_compiler('c')
################################################################################
# Binaries and include location
bins_dir = join_paths(meson.current_source_dir(), 'devialet/binaries')
inc_dir = './devialet/binaries/include'
################################################################################
# Locate OS specific binary
if os.startswith('linux')
  host_machine_to_directory_name = {
    'x86_64':'x86_64',
    'arm':'armv7l',
    'aarch64':'aarch64',
  }
  lib_dir = join_paths(bins_dir, host_machine_to_directory_name[cpu])
else
  # To do:
  error('Unsupported OS: ' + os)
endif
################################################################################
# Get the library
blas_lib = ccompiler.find_library('blas', dirs: lib_dir)
lapack_lib = ccompiler.find_library('lapack', dirs: lib_dir)
lapacke_lib = ccompiler.find_library('lapacke', dirs: lib_dir)
################################################################################
# Create dependency
lapacke_dep = declare_dependency(
  dependencies: [blas_lib, lapack_lib, lapacke_lib],
  include_directories: include_directories(inc_dir),
)
################################################################################
