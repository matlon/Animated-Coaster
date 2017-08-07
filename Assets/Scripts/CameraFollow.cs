using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour {

    public float positionSpeed = 5.0f;
    public float rotationSpeed = 1.0f;
    public Transform target;

    void LateUpdate () {

        transform.position = Vector3.Lerp(transform.position, target.position, positionSpeed * Time.deltaTime);
        transform.rotation = Quaternion.Lerp(transform.rotation, target.rotation, rotationSpeed * Time.deltaTime);
       // transform.LookAt(target);
    }
}