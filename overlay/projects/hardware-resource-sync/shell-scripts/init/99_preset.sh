# DO GPIO 输出引脚
echo 5 > /sys/class/gpio/export
echo 6 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio5/direction
echo out > /sys/class/gpio/gpio6/direction
chmod -R 777 /sys/class/gpio/gpio5
chmod -R 777 /sys/class/gpio/gpio6

# DI GPIO 输入引脚
echo 103 > /sys/class/gpio/export
echo 97 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio103/direction
echo in > /sys/class/gpio/gpio97/direction
chmod -R 777 /sys/class/gpio/gpio103
chmod -R 777 /sys/class/gpio/gpio97

# PT100 空白 GPIO 输出引脚
echo 74 > /sys/class/gpio/export
echo 73 > /sys/class/gpio/export
echo 86 > /sys/class/gpio/export
echo 85 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio74/direction
echo out > /sys/class/gpio/gpio73/direction
echo out > /sys/class/gpio/gpio86/direction
echo out > /sys/class/gpio/gpio85/direction
chmod -R 777 /sys/class/gpio/gpio74
chmod -R 777 /sys/class/gpio/gpio73
chmod -R 777 /sys/class/gpio/gpio86
chmod -R 777 /sys/class/gpio/gpio85

# PT100 GPIO 输入引脚
echo 0 > /sys/class/gpio/export
echo 16 > /sys/class/gpio/export
echo 104 > /sys/class/gpio/export
echo 110 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio0/direction
echo in > /sys/class/gpio/gpio16/direction
echo in > /sys/class/gpio/gpio104/direction
echo in > /sys/class/gpio/gpio110/direction
chmod -R 777 /sys/class/gpio/gpio0
chmod -R 777 /sys/class/gpio/gpio16
chmod -R 777 /sys/class/gpio/gpio104
chmod -R 777 /sys/class/gpio/gpio110

# PT100 CS 输入引脚
echo 22 > /sys/class/gpio/export
echo 40 > /sys/class/gpio/export
echo 41 > /sys/class/gpio/export
echo 148 > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio22/direction
echo in > /sys/class/gpio/gpio40/direction
echo in > /sys/class/gpio/gpio41/direction
echo in > /sys/class/gpio/gpio148/direction
chmod -R 777 /sys/class/gpio/gpio22
chmod -R 777 /sys/class/gpio/gpio40
chmod -R 777 /sys/class/gpio/gpio41
chmod -R 777 /sys/class/gpio/gpio148

# PWM 引脚
echo 0 > /sys/class/pwm/pwmchip2/export
echo 0 > /sys/class/pwm/pwmchip3/export
echo 1000000000 > /sys/class/pwm/pwmchip2/pwm0/period
echo 1000000000 > /sys/class/pwm/pwmchip3/pwm0/period
echo "normal" > /sys/class/pwm/pwmchip2/pwm0/polarity
echo "normal" > /sys/class/pwm/pwmchip3/pwm0/polarity
chmod -R 777 /sys/class/pwm/pwmchip2
chmod -R 777 /sys/class/pwm/pwmchip3


# SPI 引脚
chmod -R 777 /dev/spi*