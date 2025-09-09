# Installing Fedora (Step-by-Step Guide)

This guide explains how to install Fedora and set up the required tools for this course. Following these steps will give you an environment suitable for the entire Master’s program.

Note that Dual boot is not covered in this guide.

## Requirements

To install Fedora, you will need to:

- Make a complete backup of all your data (Installation will **permanently** delete everything already on the computer.)
- Grab a USB Stick, ~10GB should be enough. **Note that the stick will be wiped out**
- A working computer to install Fedora on the USB stick.

## Downloading Fedora

First, you should go to [the Fedora website (fedoraproject.org)](https://fedoraproject.org/workstation/), then download and install the **Fedora Media Writer**. Make sure you've plugged your USB Stick, then follow these steps:

<figure markdown="span">
  <img src="/annex/install_fedora/first_step.png" style="max-width:60%; width: auto;">
</figure>

---

## Fedora Version


<figure markdown="span">
  <img src="/annex/install_fedora/second_step.png" style="max-width:60%; width: auto;">
</figure>

Here, I recommend you choose either Fedora Workstation or KDE Plasma Desktop:

- **Fedora Workstation** is the official Gnome version of Fedora: It is very stable and **lightweight**. The desktop is more akin to MacOS.
- **KDE Plasma Desktop** is the official KDE Spin of Fedora. KDE is less stable and can be **very heavy**, but it's also more similar to Windows and the look-and-feel are easier to customize.

Note that you can switch between the two without reinstalling Fedora, though it requires some steps.

---

## Writing
<figure markdown="span">
  <img src="/annex/install_fedora/third_step.png" style="max-width:60%; width: auto;">
</figure>

Here, you should make sure that:

- You select the correct hardware architecture for the target computer. It most likely is Intel/AMD 64 bit.
- Select your USB Drive, here `VendorCo` should be the name of your drive.

!!! Danger
    Remember that the USB drive will be completely erased when you press Download and Write !

<figure markdown="span">
  <img src="/annex/install_fedora/fourth_step.png" style="max-width:60%; width: auto;">
</figure>

Wait for the download to be complete, then safely remove the USB stick and plug it in the computer you want to install Fedora to.

!!! Danger
    Remember to backup your important files !

## Booting on Fedora

Now, you will need to boot on the Fedora drive to begin the installation. 
When you start your device, you should see something akin to **PRESS DEL OR F2 TO ENTER BIOS SETTING**. Press the corresponding key when you see this screen until your BIOS shows up. You can restart your computer if you need to.

On some hardware, F12 or ESC may directly show a temporary boot menu.

<figure markdown="span">
  <img src="/annex/install_fedora/fifth_step.png" style="max-width:60%; width: auto;">
</figure>


You should see something *like this*. Note that it may look very different, as this menu is hardware dependant.

You should look for something named **Boot Priorities** or **Boot Order**, and modify the boot order so that the **first item is either:**

- The name of your USB Drive
- OR Something like "Fedora Live Image"
- OR "Boot from USB"

Make sure you save the settings if necessary, then exit the BIOS. **Do not modify anything else in this menu if you don't know what you're doing**.

## Installing Fedora

Now, you PC should reboot into Fedora. It's possible a Grub menu appears with multiple options, you should select the first one named "Install Fedora" OR "Start Fedora Workstation Live".

<figure markdown="span">
  <img src="/annex/install_fedora/sixth_step.png" style="max-width:60%; width: auto;">
</figure>

You should then select to "Install Fedora to Hard Drive"

<figure markdown="span">
  <img src="/annex/install_fedora/seventh_step.png" style="max-width:60%; width: auto;">
</figure>

Then:

- Select the language of your choice, though I recommend English (United States)
- Select the correct keyboard layout:
    - us for QWERTY
    - fr for AZERTY
- Click next

<figure markdown="span">
  <img src="/annex/install_fedora/eighth_step.png" style="max-width:60%; width: auto;">
</figure>

Select the disk where you want to install Fedora, and make sure you select **Use entire disk**. Then click Next.

<figure markdown="span">
  <img src="/annex/install_fedora/ninth_step.png" style="max-width:60%; width: auto;">
</figure>

We will skip encryption for this guide, directly click Next.

The next page will summarize the changes and ask you to confirm before starting the installation.
You may be asked to create a new used. Make sure to remember the password !

!!! Danger
    Make sure your device is plugged in if its a laptop !

When the installation is finished, power off the device, **THEN** remove the USB drive, then power on.
**Do not unplug the USB drive while installation is ongoing.**

Congratulations, Fedora is now installed! You can log in with the user account you created and begin installing the course packages.