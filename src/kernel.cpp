extern "C" void _start()
{
    *(int*)0xb8000 = 0x50505050;

    return;
}
