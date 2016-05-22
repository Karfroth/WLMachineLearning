module WLMachineLearning
  # Regression class
  class Regressor
    attr_reader :coefficients
    def initialize(df, feature_names, output_name, opts = {})
      @coefficients = {}
      @output_name = output_name
      @feature_names = ['Intercept'] + feature_names
      build_model(df, feature_names, output_name, opts)
    end # initialize end

    def predict(df)
      df = df.dup
      df['Intercept'] = [1.0] * df.shape[0]
      feature_names = @feature_names[1...@feature_names.length]
      df = normalize(df, feature_names, false)
      feature_matrix = df[@feature_names].to_nmatrix
      N[@weights].dot(feature_matrix.transpose).to_a
    end

    def feature_derivative(errors, feature)
      errors.dot(feature) * 2
    end

    def predict_output(feature_matrix, weights)
      weights.dot(feature_matrix.transpose)
    end # predit_out end

    def display_message(feature_matrix, step_size, stop_rmse_diff, l1_penalty, l2_penalty)
      puts 'Building Linear Regression Model...'
      puts 'Model Information'
      puts '-' * 50
      puts "Number of Features: #{feature_matrix.shape[1] - 1}"
      puts "Number of Observations: #{feature_matrix.shape[0]}"
      puts 'Training Information'
      puts '-' * 50
      puts "Step Size: #{step_size}"
      puts "Stop Condition: RMSE descent < #{stop_rmse_diff}"
      puts "L1 Penalty: #{l1_penalty}"
      puts "L2 Penalty: #{l2_penalty}"
      puts '--------------------------------------------------'
    end

    def normalize(df, feature_names, is_train)
      if is_train
        @train_range = df.max - df.min
        @train_mean = df.mean
      end
      feature_names.each do |name|
        df[name] = (df[name] - @train_mean[name]) / @train_range[name]
      end
      df
    end

    def get_cost(output, weights, feature_matrix, step_size)
      m = feature_matrix.shape[0]
      weights_matrix = N[weights]
      predictions = predict_output(feature_matrix, weights_matrix)
      errors = predictions - output
      error_square = (errors**2).to_a.sum
      mse = (1.0 / m) * error_square
      gradient = errors.dot(feature_matrix) * 2 / m
      weights_matrix -= gradient * step_size
      weights = weights_matrix.to_a
      mean_output = output.to_a.sum / m
      [weights, mse, gradient]
    end

    def gradient_decent(weights, feature_matrix, output, step_size, stop_rmse_diff)
      need_work = true
      num_iter = 0
      rmse_old = 0
      while need_work
        num_iter += 1
        weights, mse, gradient = get_cost(output, weights, feature_matrix, step_size)
        rmse = Math.sqrt(mse)
        if num_iter > 1
          need_work = false if rmse_old - rmse < stop_rmse_diff
        end
        need_work = false if num_iter >= 10000
        puts "num_iter: #{num_iter}, differnce: #{rmse_old - rmse}" if num_iter % 100 == 0
        rmse_old = rmse

      end # While end
      puts "RMSE is #{rmse}"
      [num_iter, weights]
    end # def end

    def build_model(df, feature_names, output_name, opts = {})
      weights = opts.fetch(:weights, [1.0] * (feature_names.length + 1))
      step_size = opts.fetch(:step_size, 0.1)
      stop_rmse_diff = opts.fetch(:stop_rmse_diff, 10)
      l1_penalty = opts.fetch(:l1_penalty, 0)
      l2_penalty = opts.fetch(:l2_penalty, 0)

      df = df.dup
      df['Intercept'] = Daru::Vector.new([1.0] * df.shape[0], name: 'Intercept')
      feature_df = df[['Intercept'] + feature_names]
      feature_df = normalize(feature_df, feature_names, true)
      feature_matrix = feature_df.to_nmatrix
      output = N[df[output_name].to_a]

      display_message(feature_matrix, step_size, stop_rmse_diff, l1_penalty, l2_penalty)

      num_iter, @weights = gradient_decent(weights, feature_matrix, output, step_size, stop_rmse_diff)
      (0...@weights.length).each do |i|
        @coefficients[@feature_names[i]] = @weights[i]
      end
      puts 'Done!'
      puts "Number of Iterations : #{num_iter}"
    end
  end
end
