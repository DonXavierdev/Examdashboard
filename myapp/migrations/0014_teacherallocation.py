# Generated by Django 4.1.6 on 2024-03-20 03:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('myapp', '0013_roomdata'),
    ]

    operations = [
        migrations.CreateModel(
            name='TeacherAllocation',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('prn', models.CharField(max_length=100)),
                ('room_name', models.CharField(max_length=100)),
                ('date', models.DateField()),
            ],
        ),
    ]