#!/Applications/Julia-0.3.8.app/Contents/Resources/julia/bin/julia

# function to return random position in file
function get_random_pos(rnd_num)
  return rand(0:rnd_num)
end

# main function
function main()
  # set filename
  if length(ARGS) < 2
      println(STDERR, "Usage: fastq_rnd_seek_proper.jl filename numsamples")
      exit()
  end
  filename = ARGS[1]
  numsamples = parse(Int, ARGS[2])

  # check file exists
  if !isfile(filename)
    throw(LoadError("", 0, "Filename $(filename) not found."))
  end

  # get file size
  infilesize = filesize(filename)

  # open input file
  infh = open(filename, "r")

  # iterate number of samples times
  observed = Array(Int64, 0)
  lines = Array(ASCIIString, 4)
  for i = 1:numsamples
    valid_record = false
    while !valid_record
      pos = get_random_pos(infilesize)
      seek(infh, pos)
      readuntil(infh, "\n@")
      pos = position(infh) - 1
      seek(infh, pos)
      for j in 1:4
        lines[j] = readline(infh)
      end
      if startswith(lines[1], "@") && startswith(lines[3], "+")
        if !in(pos, observed)
          valid_record = true
          push!(observed, pos)
        end
      end
    end
    print(join(lines))
  end

  # close file handle
  close(infh)
end

# call main function
main()


