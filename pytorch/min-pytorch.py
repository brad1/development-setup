# README
# train toy model on 2x + 1 to trace moving parts in pytorch

import torch  # Import PyTorch so we can create tensors, do math, and use autograd.

dtype = torch.float32  # Explicitly choose numeric precision: 32-bit floating point for all tensors in this demo.
lr = 0.1  # Explicitly choose the learning rate: how large each gradient-descent update step should be.
steps = 100  # Explicitly choose the number of training iterations to run.
use_bias = True  # Explicitly choose whether the model includes a bias term in addition to the weight.

x = torch.tensor([[1.0], [2.0]], dtype=dtype)  # Create the input data as a 2x1 matrix: two training examples, each with one feature.
y = torch.tensor([[3.0], [5.0]], dtype=dtype)  # Create the target data as a 2x1 matrix: desired outputs matching y = 2x + 1.

in_features = 1  # Explicitly state the number of input features per example.
out_features = 1  # Explicitly state the number of output features predicted per example.

w = torch.tensor([[0.0]], dtype=dtype, requires_grad=True)  # Create the full weight matrix explicitly with shape [out_features, in_features]; here it is 1x1 and trainable.
b = torch.tensor([0.0], dtype=dtype, requires_grad=True) if use_bias else None  # Create the bias explicitly with shape [out_features]; also trainable if enabled.

activation = lambda z: z  # Explicitly choose the activation function; this is the identity function, so the model is purely linear.
loss_fn = lambda pred, target: ((pred - target) ** 2).mean()  # Explicitly choose the loss function as mean squared error.

for step in range(steps):  # Repeat the training update a fixed number of times.
    z = x @ w.T  # Compute the affine pre-activation: matrix-multiply inputs [2x1] by transposed weights [1x1] to get predictions [2x1].
    z = z + b if b is not None else z  # Add the bias term to every example if bias is enabled.
    pred = activation(z)  # Apply the activation function; here this changes nothing because activation is identity.
    loss = loss_fn(pred, y)  # Measure how far predictions are from targets using the explicit MSE definition.

    loss.backward()  # Run reverse-mode autodiff to compute gradients d(loss)/d(w) and d(loss)/d(b).

    with torch.no_grad():  # Temporarily disable autograd tracking so parameter updates themselves are not added to the computation graph.
        w -= lr * w.grad  # Update the weight by moving opposite the gradient, scaled by the learning rate.
        if b is not None:  # Only update the bias if it exists.
            b -= lr * b.grad  # Update the bias the same way: subtract learning-rate-scaled gradient.

    w.grad.zero_()  # Clear the stored gradient on the weight so the next iteration starts fresh instead of accumulating gradients.
    if b is not None:  # Only clear the bias gradient if bias exists.
        b.grad.zero_()  # Clear the stored gradient on the bias for the same reason.

print("weight =", w.item())  # Print the learned scalar weight from the 1x1 weight matrix.
print("bias   =", b.item() if b is not None else None)  # Print the learned scalar bias, or None if bias was disabled.
print("dtype  =", w.dtype)  # Print the actual numeric precision used by the trained parameters.
print("pred   =", (activation(x @ w.T + b) if b is not None else activation(x @ w.T)).squeeze().tolist())  # Run the final model on the training inputs and print the resulting predictions.
