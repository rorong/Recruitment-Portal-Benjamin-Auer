Rails.configuration.stripe = {

:publishable_key => 'pk_test_0NWEnEQvnIwHqZ5wcbD5zJCY',

:secret_key => 'sk_test_9yirvVjUk38CKrdRZcXI1wPw'

}

Stripe.api_key = Rails.configuration.stripe['sk_test_9yirvVjUk38CKrdRZcXI1wPw']
