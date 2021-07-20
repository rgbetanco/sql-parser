import tensorflow as tf

# # Define module
# class CustomModule(tf.Module):

#   def __init__(self):
#     super(CustomModule, self).__init__()
#     self.v = tf.Variable(1.)

#   @tf.function
#   def __call__(self, x):
#     print('Tracing with', x)
#     return x * self.v

#   @tf.function(input_signature=[tf.TensorSpec([], tf.float32)])
#   def mutate(self, new_v):
#     self.v.assign(new_v)

# # Create module object
# module = CustomModule()

# # Export module in SavedModel format
# module(tf.constant(0.))
# tf.saved_model.save(module, './')
print(tf.__version__)
# A = tf.constant('Hello World!')
# with tf.compat.v1.Session() as sess:
#     B = sess.run(A)
#     print(B)