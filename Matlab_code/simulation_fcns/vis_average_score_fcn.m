function [avg_results, max_length] = vis_average_score_fcn(run_results_single)
%vis_average_score_fcn (visualization) calculates the average scroes for
%cells with signals with unequal lengths
max_length=0;
for try_num_cntr = 1:size(run_results_single,1)
    current_length_total = length([run_results_single{try_num_cntr}]);
    if current_length_total > max_length
        max_length = current_length_total;
    end
end
sum_avg=zeros(1, max_length);
sum_avg_cntr=zeros(1, max_length);
for length_cntr = 1:max_length
    for try_num_cntr = 1:size(run_results_single,1)
        if length_cntr <= length(run_results_single{try_num_cntr})
            if ~isnan(run_results_single{try_num_cntr}(length_cntr))
                sum_avg(length_cntr) = sum_avg(length_cntr)+run_results_single{try_num_cntr}(length_cntr);
                sum_avg_cntr(length_cntr) = sum_avg_cntr(length_cntr)+1;
            end
        end
    end
end
avg_results = sum_avg./sum_avg_cntr;
end

