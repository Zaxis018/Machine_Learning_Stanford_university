function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices.
%
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);

% You need to return the following variables correctly
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


X = [ones(m, 1) X];   % add column for bias

%% compute forward pass
z2 = X * Theta1';
a2 = sigmoid(z2);
a2 = [ones(m, 1) a2];  % add bias term to a2

z3 = a2 * Theta2';
a3 = sigmoid(z3);  % hypothesis

%% calculate loss

y_matrix = zeros(m, num_labels );
for i = 1:m  %% iterate over rows
    k = y(i); %% get value of original vector
    y_matrix(i, k) = 1;  %% set the value to 1
end

cost1 = -y_matrix .* log(a3);
cost2 = -(1 - y_matrix) .* log(1 - a3);

cost = sum(cost1(:)) + sum(cost2(:));
cost =(1/m)* cost;

theta_reg1 = Theta1;
theta_reg1(:,1) = 0;   % set first column to zero
theta_reg2 = Theta2;
theta_reg2(:,1) = 0;   % set first column to zero
reg_loss = (lambda/(2*m)) * (sum(sum(theta_reg1.^2)) + sum(sum(theta_reg2.^2)));

J = cost + reg_loss;

for i = 1:m
  % forward pass for single training sample (ith sample)
  a1 = X(i, :);
  a1 = a1';
  z2 = Theta1 * a1;
  a2 = [1 ; sigmoid(z2)]; % add bias
  z3 = Theta2 * a2;
  a3 = sigmoid(z3); % no need to add bias

  del_3 = a3 - y_matrix(i, :)';   % dL/dz3 = (a-y)
  del_2 = (Theta2' * del_3)(2:end) .* sigmoidGradient(Theta1 * a1);

  Theta1_grad = Theta1_grad + del_2 * a1';
  Theta2_grad = Theta2_grad + del_3 * a2';
end


% Implementing  Regularization derivative term --> lambda * Theta
Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + lambda * Theta1(:, 2:end);  % do not add gradients for bias term
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + lambda * Theta2(:, 2:end);

Theta1_grad = Theta1_grad / m;
Theta2_grad = Theta2_grad / m;

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];

end

