function elapsed_time_out = print_elapsed_time(begin_time, end_time, display_time)
	% display_time is a boolean that decides if the time has to be printed out or not

	elapsed_time = end_time - begin_time;
	elapsed_minutes = fix(elapsed_time/60);
	elapsed_seconds = round(rem(elapsed_time ,60));
	elapsed_time_out = [elapsed_minutes, elapsed_seconds];							% optional output vector
	if display_time
		fprintf('>> elapsed time: %i [m] %i [s]\n', elapsed_minutes, elapsed_seconds);
	end
end