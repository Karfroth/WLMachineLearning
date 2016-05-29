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

    private
    def feature_derivative(errors, feature)
      errors.dot(feature) * 2
    end

    def regulizer(m, weights, penalty, is_l2)
      weights_len = weights.shape[1]
      target_weights = weights[1...weights_len]
      (penalty / (1.0 * m)) * target_weights.dot(target_weights.transpose).to_f if is_l2
    end

    def predict_output(feature_matrix, weights)
      weights.dot(feature_matrix.transpose)
    end # predit_out end

    def display_message(feature_matrix, step_size, tolerance, l1_penalty, l2_penalty)
      puts 'Building Linear Regression Model...'
      puts '=' * 50
      puts 'Model Information'
      puts '-' * 50
      puts "Number of Features: #{feature_matrix.shape[1] - 1}"
      puts "Number of Observations: #{feature_matrix.shape[0]}"
      puts '-' * 50
      puts 'Training Information'
      puts '=' * 50
      puts '-' * 50
      puts "Tolerance: #{tolerance}"
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

    def get_cost(output, weights, feature_matrix, step_size, penalty, is_l2)
      m = feature_matrix.shape[0]
      weights_matrix = N[weights]

      ## Getting error squared
      predictions = predict_output(feature_matrix, weights_matrix)
      errors = predictions - output
      error_squared = (errors**2).to_a.sum
      ## Getting regularized term
      regul_term = regulizer(m, weights_matrix, penalty, is_l2)
      theta = weights_matrix.dup
      theta[0] = 0

      cost = (1.0 / m) * (error_squared + regul_term)
      gradient = (errors.dot(feature_matrix) + (theta * penalty)) * 2 / m
      weights_matrix -= gradient * step_size
      weights = weights_matrix.to_a
      [weights, cost, errors]
    end

    def gradient_decent(weights, feature_matrix, output, step_size, tolerance, penalty, is_l2)
      need_work = true
      num_iter = 0
      old_thing = 1
      while need_work
        num_iter += 1
        weights, cost, errors = get_cost(output, weights, feature_matrix, step_size, penalty, is_l2)
        relative_r = errors.norm2 / output.norm2
        need_work = false if relative_r <= tolerance
        need_work = false if num_iter >= 1000
        if old_thing <= relative_r
          need_work = false
          puts "No descent"
        end
        puts "num_iter: #{num_iter}, relative residual: #{relative_r}" if num_iter % 100 == 0
        old_thing = relative_r
      end # While end
      puts "Cost is #{cost}"
      [num_iter, weights]
    end # def end

    def build_model(df, feature_names, output_name, opts = {})
      weights = opts.fetch(:weights, [1.0] * (feature_names.length + 1))
      puts weights
      step_size = opts.fetch(:step_size, 0.001)
      tolerance = opts.fetch(:tol, 0.001)
      l1_penalty = opts.fetch(:l1_penalty, 0)
      l2_penalty = opts.fetch(:l2_penalty, 0.1)
      if l2_penalty > 0
        is_l2 = true
        penalty = l2_penalty
      else
        is_l2 = false
        penalty = l1_penalty
      end

      df = df.dup
      df['Intercept'] = Daru::Vector.new([1.0] * df.shape[0], name: 'Intercept')
      feature_df = df[['Intercept'] + feature_names]
      feature_df = normalize(feature_df, feature_names, true)
      feature_matrix = feature_df.to_nmatrix
      output = N[df[output_name].to_a] * 1.0

      display_message(feature_matrix, step_size, tolerance, l1_penalty, l2_penalty)

      num_iter, @weights = gradient_decent(weights, feature_matrix, output, step_size, tolerance, penalty, is_l2)
      (0...@weights.length).each do |i|
        @coefficients[@feature_names[i]] = @weights[i]
      end # enum end
      puts 'Done!'
      puts "Number of Iterations : #{num_iter}"
    end # def end
  end # class end
end # module end
