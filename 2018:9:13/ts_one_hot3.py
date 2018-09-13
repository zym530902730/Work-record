import tensorflow as tf

original_indices = tf.constant([1, 5, 3])
depth = tf.constant(10)
one_hot_encoded = tf.one_hot(indices=original_indices, depth=depth)

with tf.Session():
  print(one_hot_encoded.eval())

def decode_one_hot(batch_of_vectors):
  """Computes indices for the non-zero entries in batched one-hot vectors.

  Args:
    batch_of_vectors: A Tensor with length-N vectors, having shape [..., N].
  Returns:
    An integer Tensor with shape [...] indicating the index of the non-zero
    value in each vector.
  """
  nonzero_indices = tf.where(tf.not_equal(
      batch_of_vectors, tf.zeros_like(batch_of_vectors)))
  reshaped_nonzero_indices = tf.reshape(
      nonzero_indices[:, -1], tf.shape(batch_of_vectors)[:-1])
  return reshaped_nonzero_indices

with tf.Session():
  print(decode_one_hot(one_hot_encoded).eval())
