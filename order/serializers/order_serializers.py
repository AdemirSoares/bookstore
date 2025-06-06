from rest_framework import serializers

from order.models import Order
from product.models import Product
from product.serializers.product_serializer import ProductSerializer

from django.contrib.auth import get_user_model

User = get_user_model()


class OrderSerializer(serializers.ModelSerializer):
    product = ProductSerializer(many=True, read_only=True)
    product_ids = serializers.PrimaryKeyRelatedField(
        many=True, queryset=Product.objects.all(), write_only=True, source='product'
    )
    total = serializers.SerializerMethodField()
    user = serializers.PrimaryKeyRelatedField(queryset=User.objects.all())

    def get_total(self, instance):
        return sum([product.price for product in instance.product.all()])

    class Meta:
        model = Order
        fields = ['user', 'product', 'product_ids', 'total']